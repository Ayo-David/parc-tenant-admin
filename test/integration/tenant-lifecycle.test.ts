import { randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import pino from "pino";
import request from "supertest";
import { createApp } from "../../src/app.js";
import type { PlatformAuthorizer } from "../../src/auth/platform-authorizer.js";
import { loadConfig } from "../../src/config/env.js";
import { ApiError } from "../../src/http/api-error.js";
import { TenantLifecycleService } from "../../src/services/tenant-lifecycle-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;

class TestPlatformAuthorizer implements PlatformAuthorizer {
  public constructor(private readonly administratorId: string) {}
  public authorize(
    token: string,
    permission: string,
  ): Promise<{ administratorId: string }> {
    if (
      token !== "valid-platform-token" ||
      !["tenant.create", "tenant.application.approve"].includes(permission)
    )
      return Promise.reject(
        new ApiError(403, "FORBIDDEN", "Permission denied"),
      );
    return Promise.resolve({ administratorId: this.administratorId });
  }
}

describeDatabase("tenant application and activation", () => {
  let database: Knex;
  const administratorId = randomUUID();
  const createdTenantIds: string[] = [];
  const idempotencyRecordKeys: string[] = [];

  beforeAll(() => {
    database = knex({ client: "pg", connection: databaseUrl! });
  });

  afterAll(async () => {
    if (createdTenantIds.length > 0) {
      await database("idempotency_keys")
        .whereIn("tenant_id", createdTenantIds)
        .orWhereIn("idempotency_key", idempotencyRecordKeys)
        .delete();
      await database("outbox_events")
        .whereIn("tenant_id", createdTenantIds)
        .delete();
      await database("audit_logs")
        .whereIn("tenant_id", createdTenantIds)
        .delete();
      await database("operation_approvals")
        .whereIn(
          "operation_request_id",
          database("operation_requests")
            .select("id")
            .whereIn("tenant_id", createdTenantIds),
        )
        .delete();
      await database("operation_requests")
        .whereIn("tenant_id", createdTenantIds)
        .delete();
      await database("tenant_status_history")
        .whereIn("tenant_id", createdTenantIds)
        .delete();
      await database("tenant_profiles")
        .whereIn("tenant_id", createdTenantIds)
        .delete();
      await database("tenants").whereIn("id", createdTenantIds).delete();
    }
    await database.destroy();
  });

  function app() {
    return createApp({
      config: loadConfig({ NODE_ENV: "test" }),
      logger: pino({ enabled: false }),
      tenantLifecycle: {
        service: new TenantLifecycleService(database),
        authorizer: new TestPlatformAuthorizer(administratorId),
      },
    });
  }

  it("submits once, persists its approval request atomically, then activates once", async () => {
    const applicationKey = randomUUID();
    idempotencyRecordKeys.push(
      `tenant-application:SELF_SERVICE:${applicationKey}`,
    );
    const body = {
      legal_name: "Parc Test Microfinance",
      contact_email: "operations@example.test",
      contact_phone: "+2348012345678",
    };
    const submitted = await request(app())
      .post("/v1/tenant-applications")
      .set("Idempotency-Key", applicationKey)
      .send(body);
    expect(submitted.status).toBe(202);
    expect(submitted.body).toMatchObject({ status: "PENDING_APPROVAL" });
    expect(submitted.headers["idempotent-replayed"]).toBe("false");
    const tenantId = String((submitted.body as { id: unknown }).id);
    createdTenantIds.push(tenantId);

    const replayed = await request(app())
      .post("/v1/tenant-applications")
      .set("Idempotency-Key", applicationKey)
      .send(body);
    expect(replayed.status).toBe(202);
    expect(replayed.body).toEqual(submitted.body);
    expect(replayed.headers["idempotent-replayed"]).toBe("true");
    expect(
      await database("tenants")
        .where({ id: tenantId })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({
      count: "1",
    });
    expect(
      await database("operation_requests")
        .where({ tenant_id: tenantId, status: "PENDING" })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({ count: "1" });
    expect(
      await database("outbox_events")
        .where({
          tenant_id: tenantId,
          event_type: "tenant.application-submitted.v1",
        })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({ count: "1" });

    const activationKey = randomUUID();
    const activated = await request(app())
      .post(`/v1/tenant-applications/${tenantId}/approve`)
      .set("Authorization", "Bearer valid-platform-token")
      .set("Idempotency-Key", activationKey)
      .send();
    expect(activated.status).toBe(200);
    expect(activated.body).toMatchObject({ id: tenantId, status: "ACTIVE" });

    const activationReplay = await request(app())
      .post(`/v1/tenant-applications/${tenantId}/approve`)
      .set("Authorization", "Bearer valid-platform-token")
      .set("Idempotency-Key", activationKey)
      .send();
    expect(activationReplay.status).toBe(200);
    expect(activationReplay.headers["idempotent-replayed"]).toBe("true");
    expect(
      await database("outbox_events")
        .where({ tenant_id: tenantId, event_type: "tenant.activated.v1" })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({ count: "1" });
    expect(
      await database("tenants").where({ id: tenantId }).first("status"),
    ).toEqual({ status: "ACTIVE" });
    const invalidTransition = await request(app())
      .post(`/v1/tenant-applications/${tenantId}/approve`)
      .set("Authorization", "Bearer valid-platform-token")
      .set("Idempotency-Key", randomUUID())
      .send();
    expect(invalidTransition.status).toBe(409);
    expect((invalidTransition.body as { code: unknown }).code).toBe(
      "INVALID_TENANT_STATE",
    );
  });

  it("rejects changed idempotent input, malformed input, and unauthorized approval", async () => {
    const key = randomUUID();
    idempotencyRecordKeys.push(`tenant-application:SELF_SERVICE:${key}`);
    const initial = await request(app())
      .post("/v1/tenant-applications")
      .set("Idempotency-Key", key)
      .send({
        legal_name: "Second Parc Tenant",
        contact_email: "second@example.test",
        contact_phone: "+2349012345678",
      });
    createdTenantIds.push(String((initial.body as { id: unknown }).id));

    const conflict = await request(app())
      .post("/v1/tenant-applications")
      .set("Idempotency-Key", key)
      .send({
        legal_name: "Changed Tenant Name",
        contact_email: "second@example.test",
        contact_phone: "+2349012345678",
      });
    expect(conflict.status).toBe(409);
    expect((conflict.body as { code: unknown }).code).toBe(
      "IDEMPOTENCY_KEY_REUSED",
    );

    const invalid = await request(app())
      .post("/v1/tenant-applications")
      .set("Idempotency-Key", randomUUID())
      .send({ legal_name: "x" });
    expect(invalid.status).toBe(422);

    const unauthorized = await request(app())
      .post(
        `/v1/tenant-applications/${String((initial.body as { id: unknown }).id)}/approve`,
      )
      .set("Idempotency-Key", randomUUID())
      .send();
    expect(unauthorized.status).toBe(401);
  });

  it("enforces maker-checker separation and rolls back the idempotency claim", async () => {
    const creationKey = randomUUID();
    idempotencyRecordKeys.push(
      `tenant-application:PLATFORM_ADMIN:${creationKey}`,
    );
    const created = await request(app())
      .post("/v1/tenants")
      .set("Authorization", "Bearer valid-platform-token")
      .set("Idempotency-Key", creationKey)
      .send({
        legal_name: "Maker Checker Test",
        contact_email: "maker-checker@example.test",
        contact_phone: "+2348112345678",
      });
    expect(created.status).toBe(202);
    const tenantId = String((created.body as { id: unknown }).id);
    createdTenantIds.push(tenantId);
    const approvalKey = randomUUID();
    const response = await request(app())
      .post(`/v1/tenant-applications/${tenantId}/approve`)
      .set("Authorization", "Bearer valid-platform-token")
      .set("Idempotency-Key", approvalKey)
      .send();
    expect(response.status).toBe(403);
    expect((response.body as { code: unknown }).code).toBe(
      "MAKER_CHECKER_VIOLATION",
    );
    expect(
      await database("tenants").where({ id: tenantId }).first("status"),
    ).toEqual({ status: "PENDING" });
    expect(
      await database("idempotency_keys")
        .where({
          tenant_id: tenantId,
          idempotency_key: `tenant-activation:${approvalKey}`,
        })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({ count: "0" });
  });
});
