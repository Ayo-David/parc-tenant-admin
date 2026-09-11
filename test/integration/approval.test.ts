/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access */
import { createHash, randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import pino from "pino";
import request from "supertest";
import { createApp } from "../../src/app.js";
import type {
  AdministratorAuthorizer,
  AdministratorPrincipal,
} from "../../src/auth/platform-authorizer.js";
import { loadConfig } from "../../src/config/env.js";
import { ApprovalService } from "../../src/services/approval-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;
const serviceToken = "approval-test-service-token-at-least-32-chars";

class TestAuthorizer implements AdministratorAuthorizer {
  public principal: AdministratorPrincipal;
  public constructor(principal: AdministratorPrincipal) {
    this.principal = principal;
  }
  public authorize(): Promise<{ administratorId: string }> {
    return Promise.resolve({ administratorId: this.principal.administratorId });
  }
  public authorizeAdministrator(): Promise<AdministratorPrincipal> {
    return Promise.resolve(this.principal);
  }
}

describeDatabase("bound maker-checker approvals", () => {
  let database: Knex;
  let service: ApprovalService;
  const tenantId = randomUUID();
  const makerId = randomUUID();
  const firstCheckerId = randomUUID();
  const secondCheckerId = randomUUID();
  const authorizer = new TestAuthorizer({
    administratorId: makerId,
    tenantId,
    scope: "TENANT",
  });

  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    service = new ApprovalService(database);
    await database("tenants").insert({
      id: tenantId,
      tenant_code: `APR_${tenantId.replaceAll("-", "").slice(0, 8)}`,
      legal_name: "Approval Test Tenant",
      tenant_type: "OTHER",
      status: "ACTIVE",
    });
    await database("admin_users").insert(
      [makerId, firstCheckerId, secondCheckerId].map((id, index) => ({
        id,
        tenant_id: tenantId,
        email: `approval-${index}-${id}@example.test`,
        first_name: "Test",
        last_name: "Admin",
        status: "ACTIVE",
        is_platform_admin: false,
      })),
    );
  });

  afterAll(async () => {
    const ids = await database("operation_requests")
      .where({ tenant_id: tenantId })
      .pluck<string>("id");
    await database("operation_actions")
      .whereIn("operation_request_id", ids)
      .delete();
    await database("operation_approvals")
      .whereIn("operation_request_id", ids)
      .delete();
    await database("operation_requests")
      .where({ tenant_id: tenantId })
      .delete();
    await database("audit_logs").where({ tenant_id: tenantId }).delete();
    await database("outbox_events").where({ tenant_id: tenantId }).delete();
    await database("idempotency_keys").where({ tenant_id: tenantId }).delete();
    await database("admin_users")
      .whereIn("id", [makerId, firstCheckerId, secondCheckerId])
      .delete();
    await database("tenants").where({ id: tenantId }).delete();
    await database.destroy();
  });

  function app() {
    return createApp({
      config: loadConfig({ NODE_ENV: "test" }),
      logger: pino({ enabled: false }),
      approvals: {
        service,
        authorizer,
        serviceToken,
        allowedServices: new Set(["parc-payment"]),
      },
    });
  }

  function input(requiredApprovals = 1) {
    return {
      action: "PAYMENT_REFUND",
      resource_type: "payment",
      resource_id: randomUUID(),
      payload_hash: createHash("sha256").update(randomUUID()).digest("hex"),
      amount_minor: "125000",
      currency: "NGN",
      reason: "Exceptional refund requested",
      expires_at: new Date(Date.now() + 60_000).toISOString(),
      required_approvals: requiredApprovals,
    };
  }

  async function createApproval(requiredApprovals = 1) {
    authorizer.principal = {
      administratorId: makerId,
      tenantId,
      scope: "TENANT",
    };
    const body = input(requiredApprovals);
    const response = await request(app())
      .post("/v1/approval-requests")
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send(body);
    expect(response.status).toBe(201);
    return { body, approval: response.body as { id: string; status: string } };
  }

  it("enforces maker-checker separation and a multi-checker threshold", async () => {
    const { approval } = await createApproval(2);
    const makerDecision = await request(app())
      .post(`/v1/approval-requests/${approval.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" });
    expect(makerDecision.status).toBe(403);
    authorizer.principal = {
      administratorId: firstCheckerId,
      tenantId,
      scope: "TENANT",
    };
    const first = await request(app())
      .post(`/v1/approval-requests/${approval.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" });
    expect(first.body.status).toBe("IN_REVIEW");
    authorizer.principal = {
      administratorId: secondCheckerId,
      tenantId,
      scope: "TENANT",
    };
    const second = await request(app())
      .post(`/v1/approval-requests/${approval.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" });
    expect(second.body.status).toBe("APPROVED");
    const event = await database("outbox_events")
      .where({ aggregate_id: approval.id, event_type: "approval.decided.v1" })
      .orderBy("created_at", "desc")
      .first<{ payload: { approval_id: string; payload_hash: string } }>();
    expect(event?.payload.approval_id).toBe(approval.id);
    expect(event?.payload.payload_hash).toMatch(/^[a-f0-9]{64}$/);
  });

  it("rejects tampering and permits exactly one consuming service", async () => {
    const { body, approval } = await createApproval();
    authorizer.principal = {
      administratorId: firstCheckerId,
      tenantId,
      scope: "TENANT",
    };
    await request(app())
      .post(`/v1/approval-requests/${approval.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" })
      .expect(200);
    const headers = {
      "X-Service-Token": serviceToken,
      "X-Service-Name": "parc-payment",
      "X-Tenant-Id": tenantId,
    };
    await request(app())
      .post(`/internal/v1/approvals/${approval.id}/consume`)
      .set(headers)
      .set("Idempotency-Key", randomUUID())
      .send({ ...body, payload_hash: "0".repeat(64) })
      .expect(409);
    const consumptionKey = randomUUID();
    const consumed = await request(app())
      .post(`/internal/v1/approvals/${approval.id}/consume`)
      .set(headers)
      .set("Idempotency-Key", consumptionKey)
      .send(body);
    expect(consumed.body.status).toBe("CONSUMED");
    const replayed = await request(app())
      .post(`/internal/v1/approvals/${approval.id}/consume`)
      .set(headers)
      .set("Idempotency-Key", consumptionKey)
      .send(body);
    expect(replayed.headers["idempotent-replayed"]).toBe("true");
    await request(app())
      .post(`/internal/v1/approvals/${approval.id}/consume`)
      .set(headers)
      .set("Idempotency-Key", randomUUID())
      .send(body)
      .expect(409);
  });

  it("serializes concurrent decisions by the same checker", async () => {
    const { approval } = await createApproval(2);
    authorizer.principal = {
      administratorId: firstCheckerId,
      tenantId,
      scope: "TENANT",
    };
    const make = () =>
      request(app())
        .post(`/v1/approval-requests/${approval.id}/decisions`)
        .set("Authorization", "Bearer test")
        .set("X-Tenant-Id", tenantId)
        .set("Idempotency-Key", randomUUID())
        .send({ decision: "APPROVED" });
    const results = await Promise.all([make(), make()]);
    expect(results.map(({ status }) => status).sort()).toEqual([200, 409]);
    expect(
      await database("operation_approvals")
        .where({ operation_request_id: approval.id })
        .count<{ count: string }[]>("id as count")
        .first(),
    ).toEqual({ count: "1" });
  });

  it("records execution only for the consuming service", async () => {
    const { body, approval } = await createApproval();
    authorizer.principal = {
      administratorId: firstCheckerId,
      tenantId,
      scope: "TENANT",
    };
    await request(app())
      .post(`/v1/approval-requests/${approval.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" })
      .expect(200);
    const headers = {
      "X-Service-Token": serviceToken,
      "X-Service-Name": "parc-payment",
      "X-Tenant-Id": tenantId,
    };
    await request(app())
      .post(`/internal/v1/approvals/${approval.id}/consume`)
      .set(headers)
      .set("Idempotency-Key", randomUUID())
      .send(body)
      .expect(200);
    const key = randomUUID();
    const result = await request(app())
      .post(`/internal/v1/approvals/${approval.id}/execution`)
      .set(headers)
      .set("Idempotency-Key", key)
      .send({ status: "COMPLETED", result: { payment_id: body.resource_id } });
    expect(result.body.execution_status).toBe("COMPLETED");
    const replay = await request(app())
      .post(`/internal/v1/approvals/${approval.id}/execution`)
      .set(headers)
      .set("Idempotency-Key", key)
      .send({ status: "COMPLETED" });
    expect(replay.headers["idempotent-replayed"]).toBe("true");
  });

  it("persists expiry and rejects cross-tenant access", async () => {
    const body = {
      ...input(),
      expires_at: new Date(Date.now() + 50).toISOString(),
    };
    authorizer.principal = {
      administratorId: makerId,
      tenantId,
      scope: "TENANT",
    };
    const created = await request(app())
      .post("/v1/approval-requests")
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send(body);
    expect(created.status).toBe(201);
    const isolated = await request(app())
      .post(`/v1/approval-requests/${created.body.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", randomUUID())
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" });
    expect(isolated.status).toBe(403);
    await new Promise((resolve) => setTimeout(resolve, 75));
    authorizer.principal = {
      administratorId: firstCheckerId,
      tenantId,
      scope: "TENANT",
    };
    const expired = await request(app())
      .post(`/v1/approval-requests/${created.body.id}/decisions`)
      .set("Authorization", "Bearer test")
      .set("X-Tenant-Id", tenantId)
      .set("Idempotency-Key", randomUUID())
      .send({ decision: "APPROVED" });
    expect(expired.status).toBe(409);
    expect(
      (
        await database("operation_requests")
          .where({ id: created.body.id })
          .first<{ status: string }>("status")
      )?.status,
    ).toBe("EXPIRED");
  });
});
