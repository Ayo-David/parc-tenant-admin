/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-explicit-any, @typescript-eslint/no-misused-promises */
import { createHash } from "node:crypto";
import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";
import { OutboxRepository } from "../repositories/outbox-repository.js";
import type { ApprovalService } from "./approval-service.js";

type Scope = "SYSTEM" | "TIER" | "TENANT";
type DataType = "BOOLEAN" | "INTEGER" | "DECIMAL" | "STRING" | "JSON";

export class ConfigurationService {
  public constructor(
    private readonly database: Knex,
    private readonly approvals: ApprovalService,
  ) {}

  public async createDefinition(input: {
    key: string;
    dataType: DataType;
    validationSchema?: unknown;
    isSecret?: boolean;
    approvalPolicy?: "NONE" | "REQUIRED";
    classification?: string;
    description?: string;
    idempotencyKey: string;
  }): Promise<unknown> {
    if (
      input.classification !== undefined &&
      input.classification !== "OPERATIONAL" &&
      input.approvalPolicy === "NONE"
    )
      throw new ApiError(
        422,
        "APPROVAL_POLICY_REQUIRED",
        "Consequential configuration classifications require maker-checker approval",
      );
    return withPlatformTransaction(this.database, async (tx) => {
      const idempotency = new IdempotencyRepository(tx);
      const claim = await idempotency.claim({
        tenantId: null,
        key: `configuration-definition:${input.idempotencyKey}`,
        requestHash: hashInput(input),
        expiresAt: new Date(Date.now() + 86_400_000),
      });
      if (!claim.created) return claim.record.response_body;
      const [row] = await tx("configuration_definitions")
        .insert({
          configuration_key: input.key,
          data_type: input.dataType,
          validation_schema: input.validationSchema ?? {},
          is_secret: input.isSecret ?? false,
          approval_policy: input.approvalPolicy ?? "REQUIRED",
          classification: input.classification ?? "OPERATIONAL",
          description: input.description ?? null,
        })
        .returning("*");
      const result = definitionView(row);
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 201,
        responseBody: result,
        resourceType: "configuration_definition",
        resourceId: row.id,
      });
      return result;
    });
  }

  public async createDraft(input: {
    definitionId: string;
    scope: Scope;
    tenantId?: string;
    tierId?: string;
    value: unknown;
    effectiveFrom: Date;
    effectiveUntil?: Date;
    createdBy: string;
    reason: string;
    idempotencyKey: string;
  }): Promise<unknown> {
    return withPlatformTransaction(this.database, async (tx) => {
      const idempotency = new IdempotencyRepository(tx);
      const claim = await idempotency.claim({
        tenantId: input.tenantId ?? null,
        key: `configuration-draft:${input.idempotencyKey}`,
        requestHash: hashInput(input),
        expiresAt: new Date(Date.now() + 86_400_000),
      });
      if (!claim.created) return claim.record.response_body;
      const definition = await tx("configuration_definitions")
        .where({ id: input.definitionId, is_active: true })
        .first();
      if (!definition)
        throw new ApiError(
          404,
          "CONFIGURATION_DEFINITION_NOT_FOUND",
          "Configuration definition was not found",
        );
      validateValue(
        definition.data_type as DataType,
        definition.is_secret as boolean,
        input.value,
      );
      const current = await tx("configuration_versions")
        .where({
          definition_id: input.definitionId,
          scope: input.scope,
          tenant_id: input.tenantId ?? null,
          tier_id: input.tierId ?? null,
        })
        .max<{ max: string | null }>("version as max")
        .first();
      const [row] = await tx("configuration_versions")
        .insert({
          definition_id: input.definitionId,
          scope: input.scope,
          tenant_id: input.tenantId ?? null,
          tier_id: input.tierId ?? null,
          value: JSON.stringify(input.value),
          version: Number(current?.max ?? 0) + 1,
          effective_from: input.effectiveFrom,
          effective_until: input.effectiveUntil ?? null,
          created_by: input.createdBy,
        })
        .returning("*");
      await tx("audit_logs").insert({
        tenant_id: input.tenantId ?? null,
        actor_id: input.createdBy,
        actor_type:
          input.scope === "TENANT" ? "TENANT_ADMIN" : "PLATFORM_ADMIN",
        action: "CREATE",
        resource_type: "configuration_version",
        resource_id: row.id,
        new_values: {
          definition_id: input.definitionId,
          scope: input.scope,
          version: row.version,
          effective_from: input.effectiveFrom,
          effective_until: input.effectiveUntil ?? null,
        },
        metadata: { reason: input.reason },
      });
      const result = {
        ...versionView(row),
        approval_required: definition.approval_policy === "REQUIRED",
        approval_binding: {
          action: "CONFIGURATION_PUBLISH",
          resource_type: "configuration_version",
          resource_id: row.id,
          payload_hash: configurationPublicationPayloadHash({
            versionId: row.id,
            value: row.value,
            effectiveFrom: row.effective_from,
            effectiveUntil: row.effective_until,
          }),
        },
      };
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 201,
        responseBody: result,
        resourceType: "configuration_version",
        resourceId: row.id,
      });
      return result;
    });
  }

  public async publish(input: {
    versionId: string;
    approvalId?: string;
    publishedBy: string;
    publisherScope: "TENANT" | "PLATFORM";
    publisherTenantId: string | null;
    idempotencyKey: string;
    correlationId: string;
    expectedVersion: number;
  }): Promise<unknown> {
    const draft = await withPlatformTransaction(this.database, (tx) =>
      tx("configuration_versions as v")
        .join("configuration_definitions as d", "d.id", "v.definition_id")
        .where("v.id", input.versionId)
        .first("v.*", "d.approval_policy", "d.configuration_key"),
    );
    if (!draft)
      throw new ApiError(
        404,
        "CONFIGURATION_VERSION_NOT_FOUND",
        "Configuration version was not found",
      );
    if (
      draft.scope === "TENANT" &&
      (input.publisherScope !== "TENANT" ||
        input.publisherTenantId !== draft.tenant_id)
    )
      throw new ApiError(
        403,
        "TENANT_SCOPE_MISMATCH",
        "Tenant administrator cannot publish another tenant's configuration",
      );
    if (draft.scope !== "TENANT" && input.publisherScope !== "PLATFORM")
      throw new ApiError(
        403,
        "PLATFORM_SCOPE_REQUIRED",
        "Platform administrator scope is required",
      );
    if (
      draft.status === "PUBLISHED" &&
      draft.approval_id === (input.approvalId ?? null)
    )
      return versionView(draft);
    if (draft.status !== "DRAFT")
      throw new ApiError(
        409,
        "CONFIGURATION_VERSION_NOT_DRAFT",
        "Only draft configuration versions can be published",
      );
    const latestVersion = await withPlatformTransaction(
      this.database,
      async (tx) => {
        const result = await tx("configuration_versions")
          .where({
            definition_id: draft.definition_id,
            scope: draft.scope,
            tenant_id: draft.tenant_id,
            tier_id: draft.tier_id,
          })
          .max<{ max: string }>("version as max")
          .first();
        return Number(result?.max ?? 0);
      },
    );
    if (
      input.expectedVersion !== draft.version ||
      latestVersion !== draft.version
    )
      throw new ApiError(
        409,
        "CONFIGURATION_VERSION_CONFLICT",
        "A newer configuration draft exists or the expected version is stale",
      );
    if (draft.approval_policy === "REQUIRED") {
      if (!input.approvalId)
        throw new ApiError(
          422,
          "APPROVAL_REQUIRED",
          "A bound approval is required",
        );
      await this.approvals.consume({
        scope: draft.scope === "TENANT" ? "TENANT" : "PLATFORM",
        tenantId: draft.tenant_id,
        approvalId: input.approvalId,
        serviceName: "parc-tenant-admin",
        binding: {
          action: "CONFIGURATION_PUBLISH",
          resourceType: "configuration_version",
          resourceId: input.versionId,
          payloadHash: configurationPublicationPayloadHash({
            versionId: input.versionId,
            value: draft.value,
            effectiveFrom: draft.effective_from,
            effectiveUntil: draft.effective_until,
          }),
        },
        idempotencyKey: input.idempotencyKey,
        correlationId: input.correlationId,
      });
    }
    return withPlatformTransaction(this.database, async (tx) => {
      await tx("configuration_versions")
        .where({
          definition_id: draft.definition_id,
          scope: draft.scope,
          tenant_id: draft.tenant_id,
          tier_id: draft.tier_id,
          status: "PUBLISHED",
        })
        .update({ status: "SUPERSEDED", updated_at: new Date() });
      const [row] = await tx("configuration_versions")
        .where({
          id: input.versionId,
          status: "DRAFT",
          version: input.expectedVersion,
        })
        .update({
          status: "PUBLISHED",
          approval_id: input.approvalId ?? null,
          published_by: input.publishedBy,
          published_at: new Date(),
          updated_at: new Date(),
        })
        .returning("*");
      if (!row)
        throw new ApiError(
          409,
          "CONFIGURATION_VERSION_NOT_DRAFT",
          "Configuration version was already published or changed",
        );
      await tx("audit_logs").insert({
        tenant_id: row.tenant_id,
        actor_id: input.publishedBy,
        actor_type: row.scope === "TENANT" ? "TENANT_ADMIN" : "PLATFORM_ADMIN",
        action: "UPDATE",
        resource_type: "configuration_version",
        resource_id: row.id,
        old_values: { status: "DRAFT" },
        new_values: { status: "PUBLISHED", version: row.version },
        correlation_id: input.correlationId,
        metadata: { approval_id: input.approvalId ?? null },
      });
      const tenants = tx("tenants").where({ status: "ACTIVE" }).select("id");
      if (row.scope === "TENANT") tenants.where("id", row.tenant_id);
      else if (row.scope === "TIER") tenants.where("tier_id", row.tier_id);
      const affected = await tenants;
      for (const tenant of affected) {
        const [publication] = await tx("tenant_configuration_publications")
          .insert({
            tenant_id: tenant.id,
            configuration_version: 1,
            updated_at: new Date(),
          })
          .onConflict("tenant_id")
          .merge({
            configuration_version: tx.raw(
              "tenant_configuration_publications.configuration_version + 1",
            ),
            updated_at: new Date(),
          })
          .returning("*");
        await new OutboxRepository(tx).add({
          tenantId: tenant.id,
          aggregateType: "tenant",
          aggregateId: tenant.id,
          eventType: "tenant.configuration-changed.v1",
          idempotencyKey: `${input.idempotencyKey}:${tenant.id}`,
          correlationId: input.correlationId,
          payload: {
            tenant_id: tenant.id,
            configuration_version: Number(publication.configuration_version),
            changed_keys: [draft.configuration_key],
          },
        });
      }
      return versionView(row);
    });
  }

  public async resolve(tenantId: string, keys?: string[]): Promise<unknown> {
    return withPlatformTransaction(this.database, async (tx) => {
      const tenant = await tx("tenants")
        .where({ id: tenantId })
        .first("tier_id");
      if (!tenant)
        throw new ApiError(404, "TENANT_NOT_FOUND", "Tenant was not found");
      const rows = await tx("configuration_versions as v")
        .join("configuration_definitions as d", "d.id", "v.definition_id")
        .where("v.status", "PUBLISHED")
        .where("v.effective_from", "<=", tx.fn.now())
        .where((q) =>
          q
            .whereNull("v.effective_until")
            .orWhere("v.effective_until", ">", tx.fn.now()),
        )
        .where((q) =>
          q
            .whereNull("v.tenant_id")
            .whereNull("v.tier_id")
            .orWhere("v.tenant_id", tenantId)
            .orWhere("v.tier_id", tenant.tier_id),
        )
        .select("v.*", "d.configuration_key", "d.is_secret");
      const chosen = new Map<string, any>();
      for (const row of rows) {
        if (keys && !keys.includes(row.configuration_key)) continue;
        const rank = row.tenant_id ? 3 : row.tier_id ? 2 : 1;
        const previous = chosen.get(row.configuration_key);
        if (!previous || rank > previous.rank)
          chosen.set(row.configuration_key, { ...row, rank });
      }
      const publication = await tx("tenant_configuration_publications")
        .where({ tenant_id: tenantId })
        .first();
      return {
        tenant_id: tenantId,
        configuration_version: String(publication?.configuration_version ?? 0),
        configurations: [...chosen.values()]
          .filter((row) => !row.is_secret)
          .map((row) => ({
            key: row.configuration_key,
            value: row.value,
            source: row.scope,
            version: row.version,
            effective_from: row.effective_from,
          })),
      };
    });
  }
}

function validateValue(
  type: DataType,
  isSecret: boolean,
  value: unknown,
): void {
  if (isSecret) {
    const secret = value as Record<string, unknown> | null;
    if (
      secret === null ||
      typeof secret !== "object" ||
      Array.isArray(secret) ||
      Object.keys(secret).length !== 1 ||
      typeof secret.secret_reference !== "string" ||
      secret.secret_reference.length < 1
    )
      throw new ApiError(
        422,
        "SECRET_REFERENCE_REQUIRED",
        "Secret configurations must contain only a non-empty secret reference",
      );
  }
  if (type === "BOOLEAN" && typeof value !== "boolean")
    throw new ApiError(
      422,
      "CONFIGURATION_VALUE_INVALID",
      "Expected a boolean value",
    );
  if (type === "INTEGER" && !Number.isInteger(value))
    throw new ApiError(
      422,
      "CONFIGURATION_VALUE_INVALID",
      "Expected an integer value",
    );
  if (type === "DECIMAL" && typeof value !== "string")
    throw new ApiError(
      422,
      "CONFIGURATION_VALUE_INVALID",
      "Expected a decimal string",
    );
  if (type === "STRING" && typeof value !== "string")
    throw new ApiError(
      422,
      "CONFIGURATION_VALUE_INVALID",
      "Expected a string value",
    );
}
export function configurationPublicationPayloadHash(input: {
  versionId: string;
  value: unknown;
  effectiveFrom: Date | string;
  effectiveUntil: Date | string | null;
}): string {
  return createHash("sha256")
    .update(
      canonicalJson({
        effective_from: iso(input.effectiveFrom),
        effective_until:
          input.effectiveUntil === null ? null : iso(input.effectiveUntil),
        id: input.versionId,
        value: input.value,
      }),
    )
    .digest("hex");
}
function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value !== null && typeof value === "object")
    return `{${Object.entries(value as Record<string, unknown>)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${canonicalJson(child)}`)
      .join(",")}}`;
  return JSON.stringify(value);
}
function iso(value: Date | string): string {
  return value instanceof Date
    ? value.toISOString()
    : new Date(value).toISOString();
}
function hashInput(value: unknown): string {
  return createHash("sha256").update(canonicalJson(value)).digest("hex");
}
function definitionView(row: any): Record<string, unknown> {
  return {
    id: row.id,
    key: row.configuration_key,
    data_type: row.data_type,
    approval_policy: row.approval_policy,
    classification: row.classification,
  };
}
function versionView(row: any): Record<string, unknown> {
  return {
    id: row.id,
    definition_id: row.definition_id,
    scope: row.scope,
    tenant_id: row.tenant_id,
    tier_id: row.tier_id,
    version: row.version,
    status: row.status,
    effective_from: row.effective_from,
    effective_until: row.effective_until,
  };
}
