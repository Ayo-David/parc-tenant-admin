/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-misused-promises, @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-return */
import { randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import { ApprovalService } from "../../src/services/approval-service.js";
import { ConfigurationService } from "../../src/services/configuration-service.js";
import { MobileBootstrapService } from "../../src/services/mobile-bootstrap-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;

describeDatabase("versioned configuration", () => {
  let database: Knex;
  let approvals: ApprovalService;
  let configurations: ConfigurationService;
  let mobileBootstrap: MobileBootstrapService;
  let tierId: string;
  const tenantId = randomUUID();
  const makerId = randomUUID();
  const checkerId = randomUUID();
  const platformId = randomUUID();
  const definitionIds: string[] = [];

  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    approvals = new ApprovalService(database);
    configurations = new ConfigurationService(database, approvals);
    mobileBootstrap = new MobileBootstrapService(database, configurations);
    tierId = randomUUID();
    await database("tenant_tiers").insert({
      id: tierId,
      code: "BASIC",
      name: "Configuration Test Tier",
      is_active: true,
    });
    await database("tenants").insert({
      id: tenantId,
      tenant_code: `cfg-${tenantId.slice(0, 8)}`,
      legal_name: "Configuration Test Tenant",
      tenant_type: "OTHER",
      status: "ACTIVE",
      tier_id: tierId,
    });
    await database("admin_users").insert([
      {
        id: makerId,
        tenant_id: tenantId,
        email: `cfg-maker-${makerId}@example.test`,
        first_name: "Config",
        last_name: "Maker",
        status: "ACTIVE",
        is_platform_admin: false,
      },
      {
        id: checkerId,
        tenant_id: tenantId,
        email: `cfg-checker-${checkerId}@example.test`,
        first_name: "Config",
        last_name: "Checker",
        status: "ACTIVE",
        is_platform_admin: false,
      },
      {
        id: platformId,
        tenant_id: null,
        email: `cfg-platform-${platformId}@example.test`,
        first_name: "Config",
        last_name: "Platform",
        status: "ACTIVE",
        is_platform_admin: true,
      },
    ]);
  });

  afterAll(async () => {
    const approvalIds = await database("operation_requests")
      .where({ tenant_id: tenantId })
      .pluck<string>("id");
    await database.raw(
      "ALTER TABLE public.configuration_versions DISABLE TRIGGER trg_protect_published_configuration",
    );
    await database("configuration_versions")
      .whereIn("definition_id", definitionIds)
      .delete();
    await database.raw(
      "ALTER TABLE public.configuration_versions ENABLE TRIGGER trg_protect_published_configuration",
    );
    await database("configuration_definitions")
      .whereIn("id", definitionIds)
      .delete();
    await database("tenant_configuration_publications")
      .where({ tenant_id: tenantId })
      .delete();
    await database("operation_actions")
      .whereIn("operation_request_id", approvalIds)
      .delete();
    await database("operation_approvals")
      .whereIn("operation_request_id", approvalIds)
      .delete();
    await database("operation_requests").whereIn("id", approvalIds).delete();
    await database("outbox_events").where({ tenant_id: tenantId }).delete();
    await database("audit_logs")
      .where((q) =>
        q.where({ tenant_id: tenantId }).orWhereIn("actor_id", [platformId]),
      )
      .delete();
    await database("idempotency_keys").where({ tenant_id: tenantId }).delete();
    await database("admin_users")
      .whereIn("id", [makerId, checkerId, platformId])
      .delete();
    await database("tenants").where({ id: tenantId }).delete();
    await database("tenant_tiers").where({ id: tierId }).delete();
    await database.destroy();
  });

  async function newDefinition(
    key: string,
    approvalPolicy: "NONE" | "REQUIRED" = "NONE",
  ) {
    const value = (await configurations.createDefinition({
      key,
      dataType: "STRING",
      approvalPolicy,
      idempotencyKey: randomUUID(),
      classification:
        approvalPolicy === "REQUIRED" ? "FINANCIAL" : "OPERATIONAL",
    })) as { id: string };
    definitionIds.push(value.id);
    return value.id;
  }

  async function draftAndPublish(
    definitionId: string,
    scope: "SYSTEM" | "TIER" | "TENANT",
    value: string,
  ) {
    const draft = (await configurations.createDraft({
      definitionId,
      scope,
      ...(scope === "TENANT" ? { tenantId } : {}),
      ...(scope === "TIER" ? { tierId } : {}),
      value,
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: scope === "TENANT" ? makerId : platformId,
      reason: "Integration test configuration",
      idempotencyKey: randomUUID(),
    })) as any;
    await configurations.publish({
      versionId: draft.id,
      publishedBy: scope === "TENANT" ? makerId : platformId,
      publisherScope: scope === "TENANT" ? "TENANT" : "PLATFORM",
      publisherTenantId: scope === "TENANT" ? tenantId : null,
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
      expectedVersion: draft.version,
    });
    return draft;
  }

  it("resolves deterministic system, tier, then tenant precedence and emits a versioned change", async () => {
    const definitionId = await newDefinition(`limits.test.${randomUUID()}`);
    await draftAndPublish(definitionId, "SYSTEM", "system");
    await draftAndPublish(definitionId, "TIER", "tier");
    await draftAndPublish(definitionId, "TENANT", "tenant");
    const resolved = (await configurations.resolve(tenantId)) as any;
    expect(resolved.configurations).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ value: "tenant", source: "TENANT" }),
      ]),
    );
    expect(Number(resolved.configuration_version)).toBe(3);
    const event = await database("outbox_events")
      .where({
        tenant_id: tenantId,
        event_type: "tenant.configuration-changed.v1",
      })
      .orderBy("created_at", "desc")
      .first();
    expect(event.payload).toMatchObject({
      tenant_id: tenantId,
      configuration_version: 3,
    });
  });

  it("resolves an active tenant mobile bootstrap without exposing secret configuration", async () => {
    await expect(
      mobileBootstrap.resolve({
        tenantSlug: `cfg-${tenantId.slice(0, 8)}`,
        appVersion: "1.0.0",
        platform: "android",
      }),
    ).resolves.toMatchObject({
      tenant_id: tenantId,
      minimum_supported_version: "1.0.0",
      maintenance: false,
      features: expect.any(Object),
    });
    await expect(
      mobileBootstrap.resolve({
        tenantSlug: `cfg-${tenantId.slice(0, 8)}`,
        appVersion: "invalid",
        platform: "ios",
      }),
    ).rejects.toMatchObject({ code: "APP_VERSION_INVALID" });
  });

  it("requires and consumes the exact maker-checker approval for financial publication", async () => {
    const definitionId = await newDefinition(
      `pricing.test.${randomUUID()}`,
      "REQUIRED",
    );
    const draft = (await configurations.createDraft({
      definitionId,
      scope: "TENANT",
      tenantId,
      value: "125",
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: makerId,
      reason: "Financial configuration test",
      idempotencyKey: randomUUID(),
    })) as any;
    await expect(
      configurations.publish({
        versionId: draft.id,
        publishedBy: makerId,
        publisherScope: "TENANT",
        publisherTenantId: tenantId,
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
        expectedVersion: draft.version,
      }),
    ).rejects.toMatchObject({ code: "APPROVAL_REQUIRED" });
    const request = await approvals.create({
      scope: "TENANT",
      tenantId,
      makerId,
      binding: {
        action: draft.approval_binding.action,
        resourceType: draft.approval_binding.resource_type,
        resourceId: draft.id,
        payloadHash: draft.approval_binding.payload_hash,
      },
      reason: "Approve financial configuration",
      expiresAt: new Date(Date.now() + 60_000),
      requiredApprovals: 1,
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    await approvals.decide({
      scope: "TENANT",
      tenantId,
      approvalId: request.result.id,
      checkerId,
      decision: "APPROVED",
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    const published = (await configurations.publish({
      versionId: draft.id,
      approvalId: request.result.id,
      publishedBy: makerId,
      publisherScope: "TENANT",
      publisherTenantId: tenantId,
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
      expectedVersion: draft.version,
    })) as any;
    expect(published.status).toBe("PUBLISHED");
    expect(
      (
        await database("operation_requests")
          .where({ id: request.result.id })
          .first()
      ).status,
    ).toBe("CONSUMED");
    expect(
      await database("audit_logs")
        .where({ resource_id: draft.id })
        .count("id as count")
        .first(),
    ).toMatchObject({ count: "2" });
  });

  it("binds configuration publication to the administrator scope and tenant", async () => {
    const definitionId = await newDefinition(`scope.test.${randomUUID()}`);
    const tenantDraft = (await configurations.createDraft({
      definitionId,
      scope: "TENANT",
      tenantId,
      value: "tenant-only",
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: makerId,
      reason: "Tenant scope isolation test",
      idempotencyKey: randomUUID(),
    })) as any;
    await expect(
      configurations.publish({
        versionId: tenantDraft.id,
        publishedBy: makerId,
        publisherScope: "TENANT",
        publisherTenantId: randomUUID(),
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
        expectedVersion: tenantDraft.version,
      }),
    ).rejects.toMatchObject({ code: "TENANT_SCOPE_MISMATCH" });

    const systemDraft = (await configurations.createDraft({
      definitionId,
      scope: "SYSTEM",
      value: "platform-only",
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: platformId,
      reason: "Platform scope isolation test",
      idempotencyKey: randomUUID(),
    })) as any;
    await expect(
      configurations.publish({
        versionId: systemDraft.id,
        publishedBy: makerId,
        publisherScope: "TENANT",
        publisherTenantId: tenantId,
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
        expectedVersion: systemDraft.version,
      }),
    ).rejects.toMatchObject({ code: "PLATFORM_SCOPE_REQUIRED" });
  });

  it("rejects stale publication and plaintext secret values", async () => {
    const definitionId = await newDefinition(`security.test.${randomUUID()}`);
    const first = (await configurations.createDraft({
      definitionId,
      scope: "TENANT",
      tenantId,
      value: "first",
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: makerId,
      reason: "First draft",
      idempotencyKey: randomUUID(),
    })) as any;
    await configurations.createDraft({
      definitionId,
      scope: "TENANT",
      tenantId,
      value: "second",
      effectiveFrom: new Date(Date.now() - 1000),
      createdBy: makerId,
      reason: "Second draft",
      idempotencyKey: randomUUID(),
    });
    await expect(
      configurations.publish({
        versionId: first.id,
        publishedBy: makerId,
        publisherScope: "TENANT",
        publisherTenantId: tenantId,
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
        expectedVersion: first.version,
      }),
    ).rejects.toMatchObject({ code: "CONFIGURATION_VERSION_CONFLICT" });
    const secret = (await configurations.createDefinition({
      key: `security.secret.${randomUUID()}`,
      dataType: "JSON",
      isSecret: true,
      approvalPolicy: "NONE",
      idempotencyKey: randomUUID(),
    })) as { id: string };
    definitionIds.push(secret.id);
    await expect(
      configurations.createDraft({
        definitionId: secret.id,
        scope: "TENANT",
        tenantId,
        value: { plaintext: "never" },
        effectiveFrom: new Date(),
        createdBy: makerId,
        reason: "Secret test",
        idempotencyKey: randomUUID(),
      }),
    ).rejects.toMatchObject({ code: "SECRET_REFERENCE_REQUIRED" });
  });
});
