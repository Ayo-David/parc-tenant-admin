import { createHash } from "node:crypto";
import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";
import { OutboxRepository } from "../repositories/outbox-repository.js";
import type { ApprovalService } from "./approval-service.js";

export interface ProviderSelectionCommand {
  tenantId: string;
  capability: string;
  currency: string | null;
  provider: string;
  approvalId: string;
  selectedBy: string;
  reason: string;
  idempotencyKey: string;
  correlationId: string;
}

interface SelectionRow {
  id: string;
  tenant_id: string;
  capability: string;
  currency: string | null;
  provider_code: string;
  version: number;
  approval_id: string | null;
  selected_by: string | null;
  reason: string | null;
  selected_at: Date;
}

export class ProviderSelectionService {
  public constructor(
    private readonly database: Knex,
    private readonly approvals: ApprovalService,
  ) {}

  public listAvailable(
    capability?: string,
    currency?: string,
  ): Promise<unknown[]> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const query = transaction("provider_capabilities as c")
        .join("provider_catalog as p", "p.provider_code", "c.provider_code")
        .where({ "p.is_enabled": true, "c.is_enabled": true })
        .whereIn("p.availability", ["AVAILABLE", "DEGRADED"])
        .whereIn("c.availability", ["AVAILABLE", "DEGRADED"])
        .select(
          "c.id",
          "p.provider_code",
          "p.display_name",
          "p.category",
          "c.capability",
          "c.currency",
          "c.availability",
        )
        .orderBy(["c.capability", "p.provider_code"]);
      if (capability !== undefined) query.andWhere("c.capability", capability);
      if (currency !== undefined) query.andWhere("c.currency", currency);
      return query;
    });
  }

  public async select(
    input: ProviderSelectionCommand,
  ): Promise<{ replayed: boolean; result: SelectionView }> {
    const candidates = await this.listAvailable(
      input.capability,
      input.currency ?? undefined,
    );
    if (
      !candidates.some(
        (candidate) =>
          (candidate as { provider_code?: string }).provider_code ===
          input.provider,
      )
    )
      throw new ApiError(
        422,
        "PROVIDER_UNAVAILABLE",
        "Provider is not available for this capability",
      );
    const payloadHash = providerSelectionPayloadHash(input);
    await this.approvals.consume({
      scope: "TENANT",
      tenantId: input.tenantId,
      approvalId: input.approvalId,
      serviceName: "parc-tenant-admin",
      binding: {
        action: "TENANT_PROVIDER_CHANGE",
        resourceType: "tenant",
        resourceId: input.tenantId,
        payloadHash,
      },
      idempotencyKey: input.idempotencyKey,
      correlationId: input.correlationId,
    });
    return withPlatformTransaction(this.database, async (transaction) => {
      const idempotency = new IdempotencyRepository(transaction);
      const claim = await idempotency.claim({
        tenantId: input.tenantId,
        key: `provider-selection:${input.idempotencyKey}`,
        requestHash: hash(input),
        expiresAt: new Date(Date.now() + 86_400_000),
      });
      if (!claim.created) {
        if (claim.record.status !== "COMPLETED")
          throw new ApiError(
            409,
            "IDEMPOTENCY_REQUEST_IN_PROGRESS",
            "An equivalent request is in progress",
          );
        return {
          replayed: true,
          result: claim.record.response_body as SelectionView,
        };
      }
      const available = await transaction("provider_capabilities as c")
        .join("provider_catalog as p", "p.provider_code", "c.provider_code")
        .where({
          "c.provider_code": input.provider,
          "c.capability": input.capability,
          "c.is_enabled": true,
          "p.is_enabled": true,
        })
        .whereRaw("c.currency IS NOT DISTINCT FROM ?", [input.currency])
        .whereIn("c.availability", ["AVAILABLE", "DEGRADED"])
        .whereIn("p.availability", ["AVAILABLE", "DEGRADED"])
        .first<{ provider_code: string }>("c.provider_code");
      if (available === undefined)
        throw new ApiError(
          422,
          "PROVIDER_UNAVAILABLE",
          "Provider is not available for this capability",
        );
      const existing = await transaction<SelectionRow>(
        "tenant_provider_selections",
      )
        .where({ tenant_id: input.tenantId, capability: input.capability })
        .whereRaw("currency IS NOT DISTINCT FROM ?", [input.currency])
        .forUpdate()
        .first();
      const version = (existing?.version ?? 0) + 1;
      const values = {
        tenant_id: input.tenantId,
        capability: input.capability,
        currency: input.currency,
        provider_code: input.provider,
        version,
        approval_id: input.approvalId,
        selected_by: input.selectedBy,
        reason: input.reason,
        selected_at: new Date(),
        updated_at: new Date(),
      };
      const [row] =
        existing === undefined
          ? await transaction("tenant_provider_selections")
              .insert(values)
              .returning<SelectionRow[]>("*")
          : await transaction("tenant_provider_selections")
              .where({ id: existing.id })
              .update(values)
              .returning<SelectionRow[]>("*");
      if (row === undefined)
        throw new Error("Provider selection returned no row");
      await transaction("tenant_provider_selection_history").insert({
        selection_id: row.id,
        tenant_id: row.tenant_id,
        capability: row.capability,
        currency: row.currency,
        previous_provider_code: existing?.provider_code ?? null,
        provider_code: row.provider_code,
        version: row.version,
        approval_id: row.approval_id,
        selected_by: row.selected_by,
        reason: row.reason,
      });
      await transaction("audit_logs").insert({
        tenant_id: row.tenant_id,
        actor_id: input.selectedBy,
        actor_type: "TENANT_ADMIN",
        action: "UPDATE",
        resource_type: "tenant_provider_selection",
        resource_id: row.id,
        correlation_id: input.correlationId,
        old_values:
          existing === undefined
            ? null
            : { provider: existing.provider_code, version: existing.version },
        new_values: {
          provider: row.provider_code,
          version: row.version,
          capability: row.capability,
          currency: row.currency,
        },
        metadata: { approval_id: row.approval_id },
      });
      await new OutboxRepository(transaction).add({
        tenantId: row.tenant_id,
        aggregateType: "tenant",
        aggregateId: row.tenant_id,
        eventType: "tenant.provider-changed.v1",
        idempotencyKey: input.idempotencyKey,
        correlationId: input.correlationId,
        payload: {
          tenant_id: row.tenant_id,
          capability: row.capability,
          currency: row.currency,
          previous_provider: existing?.provider_code ?? null,
          provider: row.provider_code,
          version: row.version,
          approval_id: row.approval_id,
          changed_at: row.selected_at.toISOString(),
        },
      });
      const result = selectionView(row);
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 200,
        responseBody: result,
        resourceType: "tenant_provider_selection",
        resourceId: row.id,
      });
      return { replayed: false, result };
    });
  }

  public resolve(
    tenantId: string,
    capability: string,
    currency: string | null,
  ): Promise<SelectionView> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const row = await transaction("tenant_provider_selections as s")
        .join("provider_catalog as p", "p.provider_code", "s.provider_code")
        .join("provider_capabilities as c", function () {
          this.on("c.provider_code", "s.provider_code")
            .andOn("c.capability", "s.capability")
            .andOnVal("c.currency", currency);
        })
        .where({
          "s.tenant_id": tenantId,
          "s.capability": capability,
          "p.is_enabled": true,
          "c.is_enabled": true,
        })
        .whereRaw("s.currency IS NOT DISTINCT FROM ?", [currency])
        .whereIn("p.availability", ["AVAILABLE", "DEGRADED"])
        .whereIn("c.availability", ["AVAILABLE", "DEGRADED"])
        .first<SelectionRow>("s.*");
      if (row !== undefined) return selectionView(row, "TENANT_OVERRIDE");
      const fallback = await transaction("provider_defaults as d")
        .join("provider_catalog as p", "p.provider_code", "d.provider_code")
        .join("provider_capabilities as c", function () {
          this.on("c.provider_code", "d.provider_code")
            .andOn("c.capability", "d.capability")
            .andOnVal("c.currency", currency);
        })
        .where({
          "d.capability": capability,
          "p.is_enabled": true,
          "c.is_enabled": true,
        })
        .whereRaw("d.currency IS NOT DISTINCT FROM ?", [currency])
        .whereIn("p.availability", ["AVAILABLE", "DEGRADED"])
        .whereIn("c.availability", ["AVAILABLE", "DEGRADED"])
        .first<{
          id: string;
          capability: string;
          currency: string | null;
          provider_code: string;
          version: number;
          created_at: Date;
        }>("d.*");
      if (fallback === undefined)
        throw new ApiError(
          404,
          "PROVIDER_SELECTION_NOT_FOUND",
          "No available provider selection or platform default exists",
        );
      return {
        id: fallback.id,
        tenant_id: tenantId,
        capability: fallback.capability,
        currency: fallback.currency,
        provider: fallback.provider_code,
        version: fallback.version,
        approval_id: null,
        selected_at: fallback.created_at.toISOString(),
        source: "PLATFORM_DEFAULT",
      };
    });
  }

  public async setAvailability(input: {
    capabilityId: string;
    isEnabled: boolean;
    availability: "AVAILABLE" | "DEGRADED" | "UNAVAILABLE";
    approvalId: string;
    changedBy: string;
    reason: string;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<unknown> {
    const capability = await withPlatformTransaction(
      this.database,
      async (transaction) =>
        transaction("provider_capabilities")
          .where({ id: input.capabilityId })
          .first<{
            id: string;
            provider_code: string;
            capability: string;
            currency: string | null;
          }>(),
    );
    if (capability === undefined)
      throw new ApiError(
        404,
        "PROVIDER_CAPABILITY_NOT_FOUND",
        "Provider capability not found",
      );
    const payloadHash = providerCapabilityPayloadHash(input);
    await this.approvals.consume({
      scope: "PLATFORM",
      tenantId: null,
      approvalId: input.approvalId,
      serviceName: "parc-tenant-admin",
      binding: {
        action: "PROVIDER_CAPABILITY_CHANGE",
        resourceType: "provider_capability",
        resourceId: capability.id,
        payloadHash,
      },
      idempotencyKey: input.idempotencyKey,
      correlationId: input.correlationId,
    });
    return withPlatformTransaction(this.database, async (transaction) => {
      const replay = await transaction(
        "provider_capability_availability_history",
      )
        .where({ approval_id: input.approvalId })
        .first<{ provider_capability_id: string }>("provider_capability_id");
      if (replay !== undefined) {
        if (replay.provider_capability_id !== capability.id)
          throw new ApiError(
            409,
            "APPROVAL_ALREADY_USED",
            "Approval was used for another capability",
          );
        return transaction("provider_capabilities")
          .where({ id: capability.id })
          .first<{
            id: string;
            provider_code: string;
            capability: string;
            currency: string | null;
            is_enabled: boolean;
            availability: string;
          }>();
      }
      const current = await transaction("provider_capabilities")
        .where({ id: capability.id })
        .forUpdate()
        .first<{ is_enabled: boolean; availability: string }>();
      if (current === undefined)
        throw new ApiError(
          404,
          "PROVIDER_CAPABILITY_NOT_FOUND",
          "Provider capability not found",
        );
      await transaction("provider_capabilities")
        .where({ id: capability.id })
        .update({
          is_enabled: input.isEnabled,
          availability: input.availability,
          updated_by: input.changedBy,
          updated_at: transaction.fn.now(),
        });
      await transaction("provider_catalog")
        .where({ provider_code: capability.provider_code })
        .update({
          is_enabled: input.isEnabled,
          availability: input.availability,
          updated_at: transaction.fn.now(),
        });
      await transaction("provider_capability_availability_history").insert({
        provider_capability_id: capability.id,
        provider_code: capability.provider_code,
        capability: capability.capability,
        currency: capability.currency,
        previous_is_enabled: current.is_enabled,
        previous_availability: current.availability,
        is_enabled: input.isEnabled,
        availability: input.availability,
        approval_id: input.approvalId,
        changed_by: input.changedBy,
        reason: input.reason,
      });
      return {
        id: capability.id,
        provider_code: capability.provider_code,
        capability: capability.capability,
        currency: capability.currency,
        is_enabled: input.isEnabled,
        availability: input.availability,
      };
    });
  }
}

export interface SelectionView {
  id: string;
  tenant_id: string;
  capability: string;
  currency: string | null;
  provider: string;
  version: number;
  approval_id: string | null;
  selected_at: string;
  source: "PLATFORM_DEFAULT" | "TENANT_OVERRIDE";
}
function selectionView(
  row: SelectionRow,
  source: SelectionView["source"] = "TENANT_OVERRIDE",
): SelectionView {
  return {
    id: row.id,
    tenant_id: row.tenant_id,
    capability: row.capability,
    currency: row.currency,
    provider: row.provider_code,
    version: row.version,
    approval_id: row.approval_id,
    selected_at: row.selected_at.toISOString(),
    source,
  };
}
function hash(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}
export function providerSelectionPayloadHash(
  input: Pick<
    ProviderSelectionCommand,
    "tenantId" | "capability" | "currency" | "provider"
  >,
): string {
  return hash({
    tenant_id: input.tenantId,
    capability: input.capability,
    currency: input.currency,
    provider: input.provider,
  });
}

export function providerCapabilityPayloadHash(input: {
  capabilityId: string;
  isEnabled: boolean;
  availability: "AVAILABLE" | "DEGRADED" | "UNAVAILABLE";
}): string {
  return hash({
    provider_capability_id: input.capabilityId,
    is_enabled: input.isEnabled,
    availability: input.availability,
  });
}
