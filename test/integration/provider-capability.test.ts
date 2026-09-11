/* eslint-disable @typescript-eslint/no-unnecessary-type-assertion */
import { randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import { ApprovalService } from "../../src/services/approval-service.js";
import {
  ProviderSelectionService,
  providerCapabilityPayloadHash,
} from "../../src/services/provider-selection-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;

describeDatabase("platform provider capability management", () => {
  let database: Knex;
  const makerId = randomUUID();
  const checkerId = randomUUID();
  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    await database("admin_users").insert(
      [makerId, checkerId].map((id, index) => ({
        id,
        tenant_id: null,
        email: `capability-${index}-${id}@example.test`,
        first_name: "Platform",
        last_name: "Admin",
        status: "ACTIVE",
        is_platform_admin: true,
      })),
    );
  });
  afterAll(async () => {
    await database.raw(
      "ALTER TABLE public.provider_capability_availability_history DISABLE TRIGGER trg_protect_provider_capability_history",
    );
    const approvals = await database("provider_capability_availability_history")
      .whereIn("changed_by", [makerId, checkerId])
      .pluck<string>("approval_id");
    await database("provider_capability_availability_history")
      .whereIn("changed_by", [makerId, checkerId])
      .delete();
    await database.raw(
      "ALTER TABLE public.provider_capability_availability_history ENABLE TRIGGER trg_protect_provider_capability_history",
    );
    await database("operation_actions")
      .whereIn("operation_request_id", approvals)
      .delete();
    await database("operation_approvals")
      .whereIn("operation_request_id", approvals)
      .delete();
    await database("operation_requests").whereIn("id", approvals).delete();
    await database("provider_capabilities")
      .whereIn("updated_by", [makerId, checkerId])
      .update({ updated_by: null });
    await database("admin_users").whereIn("id", [makerId, checkerId]).delete();
    await database.destroy();
  });
  it("requires an exact consumed platform approval and records immutable history", async () => {
    const capability = await database("provider_capabilities")
      .where({
        provider_code: "PAYSTACK",
        capability: "COLLECTION",
        currency: "NGN",
      })
      .first<{ id: string }>("id");
    expect(capability).toBeDefined();
    const approvals = new ApprovalService(database);
    const service = new ProviderSelectionService(database, approvals);
    const payloadHash = providerCapabilityPayloadHash({
      capabilityId: capability!.id,
      isEnabled: true,
      availability: "AVAILABLE",
    });
    const created = await approvals.create({
      scope: "PLATFORM",
      tenantId: null,
      makerId,
      binding: {
        action: "PROVIDER_CAPABILITY_CHANGE",
        resourceType: "provider_capability",
        resourceId: capability!.id,
        payloadHash,
      },
      reason: "Enable provider capability",
      expiresAt: new Date(Date.now() + 60_000),
      requiredApprovals: 1,
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    await approvals.decide({
      scope: "PLATFORM",
      tenantId: null,
      approvalId: created.result.id,
      checkerId,
      decision: "APPROVED",
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    const result = await service.setAvailability({
      capabilityId: capability!.id,
      isEnabled: true,
      availability: "AVAILABLE",
      approvalId: created.result.id,
      changedBy: makerId,
      reason: "Enable provider capability",
      idempotencyKey: randomUUID(),
      correlationId: randomUUID(),
    });
    expect(result).toMatchObject({
      id: capability!.id,
      is_enabled: true,
      availability: "AVAILABLE",
    });
    expect(
      await database("provider_capability_availability_history")
        .where({ approval_id: created.result.id })
        .count<{ count: string }[]>("id as count")
        .first(),
    ).toEqual({ count: "1" });
    await expect(
      database("provider_capability_availability_history")
        .where({ approval_id: created.result.id })
        .update({ reason: "changed" }),
    ).rejects.toThrow(/immutable/i);
  });
});
