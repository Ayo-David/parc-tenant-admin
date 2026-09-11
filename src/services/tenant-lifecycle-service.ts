import { createHash, randomUUID } from "node:crypto";
import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";
import { OutboxRepository } from "../repositories/outbox-repository.js";

export interface TenantApplicationInput {
  legalName: string;
  contactEmail: string;
  contactPhone: string;
}

export interface TenantApplicationResult {
  id: string;
  tenant_code: string;
  status: "PENDING_APPROVAL";
  submitted_at: string;
}

export interface TenantActivationResult {
  id: string;
  tenant_code: string;
  status: "ACTIVE";
  activated_at: string;
}

interface StoredTenant {
  id: string;
  tenant_code: string;
  legal_name: string;
  tenant_type: string;
  status: "PENDING" | "ACTIVE" | "SUSPENDED" | "DEACTIVATED" | "TERMINATED";
  created_at: Date;
  activated_at: Date | null;
}

export class TenantLifecycleService {
  public constructor(private readonly database: Knex) {}

  public async submit(input: {
    application: TenantApplicationInput;
    idempotencyKey: string;
    correlationId: string;
    source?: "SELF_SERVICE" | "PLATFORM_ADMIN";
    requestedBy?: string;
  }): Promise<{ replayed: boolean; result: TenantApplicationResult }> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const source = input.source ?? "SELF_SERVICE";
      const idempotency = new IdempotencyRepository(transaction);
      const claim = await idempotency.claim({
        tenantId: null,
        key: `tenant-application:${source}:${input.idempotencyKey}`,
        requestHash: hash({
          application: input.application,
          source,
          requestedBy: input.requestedBy ?? null,
        }),
        expiresAt: hoursFromNow(24),
      });
      if (!claim.created) return replay<TenantApplicationResult>(claim.record);

      const tenantId = randomUUID();
      const tenantCode = createTenantCode(
        input.application.legalName,
        tenantId,
      );
      const [tenant] = await transaction<StoredTenant>("tenants")
        .insert({
          id: tenantId,
          tenant_code: tenantCode,
          legal_name: input.application.legalName,
          tenant_type: "OTHER",
          status: "PENDING",
        })
        .returning("*");
      if (tenant === undefined)
        throw new Error("Tenant insert returned no record");

      await transaction("tenant_profiles").insert({
        tenant_id: tenant.id,
        primary_email: input.application.contactEmail,
        phone_number: input.application.contactPhone,
        contact_person_email: input.application.contactEmail,
        contact_person_phone: input.application.contactPhone,
      });
      await transaction("tenant_status_history").insert({
        tenant_id: tenant.id,
        previous_status: null,
        new_status: "PENDING",
        reason: "Tenant application submitted",
      });
      await transaction("operation_requests").insert({
        tenant_id: tenant.id,
        operation_reference: `TENANT-ACTIVATION-${tenant.id}`,
        operation_type: "TENANT_ACTIVATION",
        resource_type: "tenant",
        resource_id: tenant.id,
        requested_by: input.requestedBy ?? tenant.id,
        status: "PENDING",
        reason: "New tenant application requires Parc platform approval",
        request_data: { source },
        requires_approval: true,
        scope: "TENANT",
        payload_hash: hash({ source, tenantId: tenant.id }),
        expires_at: hoursFromNow(168),
      });
      await transaction("audit_logs").insert({
        tenant_id: tenant.id,
        actor_id: input.requestedBy ?? null,
        actor_type:
          source === "PLATFORM_ADMIN" ? "PLATFORM_ADMIN" : "APPLICANT",
        action: "CREATE",
        resource_type: "tenant_application",
        resource_id: tenant.id,
        new_values: { status: "PENDING", tenant_code: tenant.tenant_code },
        correlation_id: input.correlationId,
      });
      await new OutboxRepository(transaction).add({
        tenantId: tenant.id,
        aggregateType: "tenant",
        aggregateId: tenant.id,
        eventType: "tenant.application-submitted.v1",
        idempotencyKey: input.idempotencyKey,
        correlationId: input.correlationId,
        payload: {
          tenant_id: tenant.id,
          tenant_code: tenant.tenant_code,
          legal_name: tenant.legal_name,
          submitted_at: tenant.created_at.toISOString(),
        },
      });
      const result: TenantApplicationResult = {
        id: tenant.id,
        tenant_code: tenant.tenant_code,
        status: "PENDING_APPROVAL",
        submitted_at: tenant.created_at.toISOString(),
      };
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 202,
        responseBody: result,
        resourceType: "tenant_application",
        resourceId: tenant.id,
      });
      return { replayed: false, result };
    });
  }

  public async approve(input: {
    tenantId: string;
    administratorId: string;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<{ replayed: boolean; result: TenantActivationResult }> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const idempotency = new IdempotencyRepository(transaction);
      const claim = await idempotency.claim({
        tenantId: input.tenantId,
        key: `tenant-activation:${input.idempotencyKey}`,
        requestHash: hash({
          tenantId: input.tenantId,
          administratorId: input.administratorId,
        }),
        expiresAt: hoursFromNow(24),
      });
      if (!claim.created) return replay<TenantActivationResult>(claim.record);

      const tenant = await transaction<StoredTenant>("tenants")
        .where({ id: input.tenantId })
        .whereNull("deleted_at")
        .forUpdate()
        .first();
      if (tenant === undefined)
        throw new ApiError(404, "TENANT_NOT_FOUND", "Tenant not found");
      if (tenant.status !== "PENDING")
        throw new ApiError(
          409,
          "INVALID_TENANT_STATE",
          "Only a pending tenant can be activated",
        );

      const operation = await transaction("operation_requests")
        .where({
          resource_type: "tenant",
          resource_id: tenant.id,
          operation_type: "TENANT_ACTIVATION",
        })
        .forUpdate()
        .first<{ id: string; requested_by: string; status: string }>();
      if (operation === undefined)
        throw new ApiError(
          409,
          "APPROVAL_REQUEST_NOT_FOUND",
          "Activation approval request not found",
        );
      if (operation.requested_by === input.administratorId)
        throw new ApiError(
          403,
          "MAKER_CHECKER_VIOLATION",
          "Maker cannot approve their own request",
        );
      if (operation.status !== "PENDING")
        throw new ApiError(
          409,
          "APPROVAL_ALREADY_DECIDED",
          "Activation approval was already decided",
        );

      const activatedAt = new Date();
      await transaction("operation_approvals").insert({
        operation_request_id: operation.id,
        approver_id: input.administratorId,
        status: "APPROVED",
        comments: "Tenant activation approved",
        approved_at: activatedAt,
      });
      await transaction("operation_requests")
        .where({ id: operation.id })
        .update({
          status: "COMPLETED",
          result_data: { tenant_id: tenant.id, status: "ACTIVE" },
          executed_at: activatedAt,
        });
      await transaction("tenants")
        .where({ id: tenant.id, status: "PENDING" })
        .update({
          status: "ACTIVE",
          activated_at: activatedAt,
          onboarding_completed_at: activatedAt,
          updated_by: input.administratorId,
        });
      await transaction("tenant_status_history").insert({
        tenant_id: tenant.id,
        previous_status: "PENDING",
        new_status: "ACTIVE",
        reason: "Approved by Parc platform administrator",
        changed_by: input.administratorId,
      });
      await transaction("audit_logs").insert({
        tenant_id: tenant.id,
        actor_id: input.administratorId,
        actor_type: "PLATFORM_ADMIN",
        action: "ACTIVATE",
        resource_type: "tenant",
        resource_id: tenant.id,
        old_values: { status: "PENDING" },
        new_values: { status: "ACTIVE" },
        correlation_id: input.correlationId,
      });
      await new OutboxRepository(transaction).add({
        tenantId: tenant.id,
        aggregateType: "tenant",
        aggregateId: tenant.id,
        eventType: "tenant.activated.v1",
        idempotencyKey: input.idempotencyKey,
        correlationId: input.correlationId,
        payload: {
          tenant_id: tenant.id,
          tenant_code: tenant.tenant_code,
          activated_at: activatedAt.toISOString(),
        },
      });
      const result: TenantActivationResult = {
        id: tenant.id,
        tenant_code: tenant.tenant_code,
        status: "ACTIVE",
        activated_at: activatedAt.toISOString(),
      };
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 200,
        responseBody: result,
        resourceType: "tenant",
        resourceId: tenant.id,
      });
      return { replayed: false, result };
    });
  }
}

function replay<T>(record: {
  status: string;
  response_status: number | null;
  response_body: unknown;
}): {
  replayed: true;
  result: T;
} {
  if (record.status !== "COMPLETED" || record.response_status === null)
    throw new ApiError(
      409,
      "IDEMPOTENCY_REQUEST_IN_PROGRESS",
      "An equivalent request is in progress",
    );
  return { replayed: true, result: record.response_body as T };
}

function hash(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

function hoursFromNow(hours: number): Date {
  return new Date(Date.now() + hours * 60 * 60 * 1000);
}

function createTenantCode(legalName: string, id: string): string {
  const prefix = legalName
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 30);
  return `${prefix.length >= 2 ? prefix : "TENANT"}_${id.replaceAll("-", "").slice(0, 8).toUpperCase()}`;
}
