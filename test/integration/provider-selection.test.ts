import { randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import { ApprovalService } from "../../src/services/approval-service.js";
import {
  ProviderSelectionService,
  providerSelectionPayloadHash,
} from "../../src/services/provider-selection-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;

describeDatabase("provider catalog and tenant selection", () => {
  let database: Knex;
  let approvals: ApprovalService;
  let selections: ProviderSelectionService;
  const tenantId = randomUUID();
  const makerId = randomUUID();
  const checkerId = randomUUID();

  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    approvals = new ApprovalService(database);
    selections = new ProviderSelectionService(database, approvals);
    await database("tenants").insert({
      id: tenantId,
      tenant_code: `PROV_${tenantId.replaceAll("-", "").slice(0, 8)}`,
      legal_name: "Provider Test Tenant",
      tenant_type: "OTHER",
      status: "ACTIVE",
    });
    await database("admin_users").insert(
      [makerId, checkerId].map((id, index) => ({
        id,
        tenant_id: tenantId,
        email: `provider-${index}-${id}@example.test`,
        first_name: "Provider",
        last_name: "Admin",
        status: "ACTIVE",
        is_platform_admin: false,
      })),
    );
  });

  beforeEach(async () => {
    await database("provider_capabilities")
      .update({
        is_enabled: false,
        availability: "UNAVAILABLE",
      })
      .whereIn("provider_code", ["PAYSTACK", "WEMA"]);
    await database("provider_catalog")
      .update({
        is_enabled: false,
        availability: "UNAVAILABLE",
      })
      .whereIn("provider_code", ["PAYSTACK", "WEMA"]);
  });

  afterAll(async () => {
    const approvalIds = await database("operation_requests")
      .where({ tenant_id: tenantId })
      .pluck<string>("id");
    await database.raw(
      "ALTER TABLE public.tenant_provider_selection_history DISABLE TRIGGER trg_protect_provider_history",
    );
    await database("tenant_provider_selection_history")
      .where({ tenant_id: tenantId })
      .delete();
    await database.raw(
      "ALTER TABLE public.tenant_provider_selection_history ENABLE TRIGGER trg_protect_provider_history",
    );
    await database("tenant_provider_selections")
      .where({ tenant_id: tenantId })
      .delete();
    await database("operation_actions")
      .whereIn("operation_request_id", approvalIds)
      .delete();
    await database("operation_approvals")
      .whereIn("operation_request_id", approvalIds)
      .delete();
    await database("outbox_events").where({ tenant_id: tenantId }).delete();
    await database("audit_logs").where({ tenant_id: tenantId }).delete();
    await database("idempotency_keys").where({ tenant_id: tenantId }).delete();
    await database("operation_requests")
      .where({ tenant_id: tenantId })
      .delete();
    await database("admin_users").whereIn("id", [makerId, checkerId]).delete();
    await database("tenants").where({ id: tenantId }).delete();
    await database.destroy();
  });

  async function approvedChange(provider: string) {
    const capability = "INTERBANK_TRANSFER";
    const currency = "NGN";
    const payloadHash = providerSelectionPayloadHash({
      tenantId,
      capability,
      currency,
      provider,
    });
    const created = await approvals.create({
      scope: "TENANT",
      tenantId,
      makerId,
      binding: {
        action: "TENANT_PROVIDER_CHANGE",
        resourceType: "tenant",
        resourceId: tenantId,
        payloadHash,
      },
      reason: "Provider routing change",
      expiresAt: new Date(Date.now() + 60_000),
      requiredApprovals: 1,
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    await approvals.decide({
      scope: "TENANT",
      tenantId,
      approvalId: created.result.id,
      checkerId,
      decision: "APPROVED",
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    return created.result.id;
  }

  it("does not list disabled providers and rejects their selection", async () => {
    expect(await selections.listAvailable("INTERBANK_TRANSFER", "NGN")).toEqual(
      [],
    );
    const approvalId = await approvedChange("PAYSTACK");
    await expect(
      selections.select({
        tenantId,
        capability: "INTERBANK_TRANSFER",
        currency: "NGN",
        provider: "PAYSTACK",
        approvalId,
        selectedBy: makerId,
        reason: "Route transfers",
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
      }),
    ).rejects.toMatchObject({ code: "PROVIDER_UNAVAILABLE" });
  });

  it("uses a consumed exact approval, versions the selection, and publishes the change", async () => {
    await database("provider_catalog")
      .where({ provider_code: "PAYSTACK" })
      .update({ is_enabled: true, availability: "AVAILABLE" });
    await database("provider_capabilities")
      .where({
        provider_code: "PAYSTACK",
        capability: "INTERBANK_TRANSFER",
        currency: "NGN",
      })
      .update({ is_enabled: true, availability: "AVAILABLE" });
    const approvalId = await approvedChange("PAYSTACK");
    const result = await selections.select({
      tenantId,
      capability: "INTERBANK_TRANSFER",
      currency: "NGN",
      provider: "PAYSTACK",
      approvalId,
      selectedBy: makerId,
      reason: "Route transfers",
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    expect(result.result).toMatchObject({ provider: "PAYSTACK", version: 1 });
    expect(
      await selections.resolve(tenantId, "INTERBANK_TRANSFER", "NGN"),
    ).toMatchObject({ provider: "PAYSTACK", version: 1 });
    expect(
      await database("tenant_provider_selection_history")
        .where({ tenant_id: tenantId })
        .count<{ count: string }[]>("id as count")
        .first(),
    ).toEqual({ count: "1" });
    expect(
      await database("outbox_events")
        .where({
          tenant_id: tenantId,
          event_type: "tenant.provider-changed.v1",
        })
        .count<{ count: string }[]>("id as count")
        .first(),
    ).toEqual({ count: "1" });
  });

  it("rejects a consumed approval bound to a different provider command", async () => {
    await database("provider_catalog")
      .where({ provider_code: "WEMA" })
      .update({ is_enabled: true, availability: "AVAILABLE" });
    await database("provider_capabilities")
      .where({
        provider_code: "WEMA",
        capability: "INTERBANK_TRANSFER",
        currency: "NGN",
      })
      .update({ is_enabled: true, availability: "AVAILABLE" });
    const approvalId = await approvedChange("PAYSTACK");
    await expect(
      selections.select({
        tenantId,
        capability: "INTERBANK_TRANSFER",
        currency: "NGN",
        provider: "WEMA",
        approvalId,
        selectedBy: makerId,
        reason: "Tamper provider",
        idempotencyKey: randomUUID(),
        correlationId: randomUUID(),
      }),
    ).rejects.toMatchObject({ code: "APPROVAL_BINDING_MISMATCH" });
  });
});
