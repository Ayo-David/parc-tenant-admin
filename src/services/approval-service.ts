import { createHash, randomUUID } from "node:crypto";
import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";
import { OutboxRepository } from "../repositories/outbox-repository.js";

export type ApprovalScope = "TENANT" | "PLATFORM";
export type ApprovalStatus =
  "PENDING" | "IN_REVIEW" | "APPROVED" | "REJECTED" | "EXPIRED" | "CONSUMED";

export interface ApprovalBinding {
  action: string;
  resourceType: string;
  resourceId: string;
  payloadHash: string;
  amountMinor?: string;
  currency?: string;
}

interface ApprovalRow {
  id: string;
  tenant_id: string | null;
  scope: ApprovalScope;
  operation_type: string;
  resource_type: string;
  resource_id: string;
  requested_by: string;
  status: ApprovalStatus | "COMPLETED" | "FAILED" | "CANCELLED";
  payload_hash: string;
  amount_minor: string | null;
  currency: string | null;
  expires_at: Date;
  required_approval_count: number;
  decided_at: Date | null;
  consumed_at: Date | null;
  consumed_by_service: string | null;
  consumption_idempotency_key: string | null;
  created_at: Date;
  operation_reference: string;
  reason: string;
  request_data: unknown;
  requires_approval: boolean;
  updated_at: Date;
}

export interface ApprovalView {
  id: string;
  scope: ApprovalScope;
  tenant_id: string | null;
  action: string;
  resource_type: string;
  resource_id: string;
  payload_hash: string;
  amount_minor?: string;
  currency?: string;
  required_approvals: number;
  status: ApprovalStatus;
  maker_id: string;
  reason: string;
  expires_at: string;
  created_at: string;
  decided_at?: string;
  consumed_at?: string;
  checker_ids?: string[];
  approved_authority_level?: number;
}

export class ApprovalService {
  public constructor(private readonly database: Knex) {}

  public create(input: {
    scope: ApprovalScope;
    tenantId: string | null;
    makerId: string;
    binding: ApprovalBinding;
    reason: string;
    expiresAt: Date;
    requiredApprovals: number;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<{ replayed: boolean; result: ApprovalView }> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const idempotency = new IdempotencyRepository(transaction);
      const claim = await idempotency.claim({
        tenantId: input.tenantId,
        key: `approval-create:${input.scope}:${input.idempotencyKey}`,
        requestHash: hash(input),
        expiresAt: hoursFromNow(24),
      });
      if (!claim.created) return replay<ApprovalView>(claim.record);
      const id = randomUUID();
      const [row] = await transaction("operation_requests")
        .insert({
          id,
          tenant_id: input.tenantId,
          scope: input.scope,
          operation_reference: `APPROVAL-${id}`,
          operation_type: input.binding.action,
          resource_type: input.binding.resourceType,
          resource_id: input.binding.resourceId,
          requested_by: input.makerId,
          reason: input.reason,
          request_data: {},
          payload_hash: input.binding.payloadHash,
          amount_minor: input.binding.amountMinor ?? null,
          currency: input.binding.currency ?? null,
          expires_at: input.expiresAt,
          required_approval_count: input.requiredApprovals,
        })
        .returning<ApprovalRow[]>("*");
      if (row === undefined) throw new Error("Approval insert returned no row");
      const result = view(row);
      await audit(
        transaction,
        row,
        input.makerId,
        "CREATE",
        input.correlationId,
      );
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 201,
        responseBody: result,
        resourceType: "approval_request",
        resourceId: row.id,
      });
      return { replayed: false, result };
    });
  }

  public async decide(input: {
    scope: ApprovalScope;
    tenantId: string | null;
    approvalId: string;
    checkerId: string;
    decision: "APPROVED" | "REJECTED";
    reason?: string;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<{ replayed: boolean; result: ApprovalView }> {
    await this.expire(input.approvalId, input.scope, input.tenantId);
    return withPlatformTransaction(this.database, async (transaction) => {
      const idempotency = new IdempotencyRepository(transaction);
      const claim = await idempotency.claim({
        tenantId: input.tenantId,
        key: `approval-decision:${input.approvalId}:${input.idempotencyKey}`,
        requestHash: hash(input),
        expiresAt: hoursFromNow(24),
      });
      if (!claim.created) return replay<ApprovalView>(claim.record);
      const row = await findLocked(
        transaction,
        input.approvalId,
        input.scope,
        input.tenantId,
      );
      if (row.requested_by === input.checkerId)
        throw new ApiError(
          403,
          "MAKER_CHECKER_VIOLATION",
          "Maker cannot decide their own request",
        );
      if (["REJECTED", "EXPIRED", "CONSUMED"].includes(row.status))
        throw new ApiError(
          409,
          "APPROVAL_ALREADY_DECIDED",
          "Approval cannot accept another decision",
        );
      if (row.expires_at.getTime() <= Date.now()) {
        await transaction("operation_requests")
          .where({ id: row.id })
          .update({ status: "EXPIRED", decided_at: transaction.fn.now() });
        throw new ApiError(
          409,
          "APPROVAL_EXPIRED",
          "Approval request has expired",
        );
      }
      const duplicate = await transaction("operation_approvals")
        .where({ operation_request_id: row.id, approver_id: input.checkerId })
        .first<{ id: string }>("id");
      if (duplicate !== undefined)
        throw new ApiError(
          409,
          "CHECKER_ALREADY_DECIDED",
          "Checker already decided this request",
        );
      const decidedAt = new Date();
      await transaction("operation_approvals").insert({
        operation_request_id: row.id,
        approver_id: input.checkerId,
        approval_level: 1,
        status: input.decision,
        comments: input.reason ?? null,
        approved_at: input.decision === "APPROVED" ? decidedAt : null,
      });
      const approved = await transaction("operation_approvals")
        .where({ operation_request_id: row.id, status: "APPROVED" })
        .count<{ count: string }[]>("id as count")
        .first();
      const status: ApprovalStatus =
        input.decision === "REJECTED"
          ? "REJECTED"
          : Number(approved?.count ?? 0) >= row.required_approval_count
            ? "APPROVED"
            : "IN_REVIEW";
      const [updated] = await transaction("operation_requests")
        .where({ id: row.id })
        .update({
          status,
          decided_at: status === "IN_REVIEW" ? null : decidedAt,
          updated_at: decidedAt,
        })
        .returning<ApprovalRow[]>("*");
      if (updated === undefined)
        throw new Error("Approval update returned no row");
      const result = view(updated);
      await audit(
        transaction,
        updated,
        input.checkerId,
        "UPDATE",
        input.correlationId,
      );
      await new OutboxRepository(transaction).add({
        tenantId: updated.tenant_id,
        aggregateType: "approval_request",
        aggregateId: updated.id,
        eventType: "approval.decided.v1",
        idempotencyKey: input.idempotencyKey,
        correlationId: input.correlationId,
        payload: {
          approval_id: updated.id,
          action: updated.operation_type,
          resource_type: updated.resource_type,
          resource_id: updated.resource_id,
          payload_hash: updated.payload_hash.trim(),
          decision: input.decision,
          status,
          checker_id: input.checkerId,
          decided_at: decidedAt.toISOString(),
        },
      });
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 200,
        responseBody: result,
        resourceType: "approval_request",
        resourceId: row.id,
      });
      return { replayed: false, result };
    });
  }

  public async consume(input: {
    scope: ApprovalScope;
    tenantId: string | null;
    approvalId: string;
    serviceName: string;
    binding: ApprovalBinding;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<{ replayed: boolean; result: ApprovalView }> {
    await this.expire(input.approvalId, input.scope, input.tenantId);
    return withPlatformTransaction(this.database, async (transaction) => {
      const row = await findLocked(
        transaction,
        input.approvalId,
        input.scope,
        input.tenantId,
      );
      if (row.status === "CONSUMED") {
        if (
          row.consumed_by_service === input.serviceName &&
          row.consumption_idempotency_key === input.idempotencyKey
        )
          return {
            replayed: true,
            result: {
              ...view(row),
              ...(await approvalEvidence(transaction, row.id)),
            },
          };
        throw new ApiError(
          409,
          "APPROVAL_ALREADY_CONSUMED",
          "Approval was already consumed",
        );
      }
      if (row.expires_at.getTime() <= Date.now()) {
        await transaction("operation_requests")
          .where({ id: row.id })
          .update({ status: "EXPIRED", decided_at: transaction.fn.now() });
        throw new ApiError(
          409,
          "APPROVAL_EXPIRED",
          "Approval request has expired",
        );
      }
      if (row.status !== "APPROVED")
        throw new ApiError(
          409,
          "APPROVAL_NOT_APPROVED",
          "Approval is not ready for consumption",
        );
      assertBinding(row, input.binding);
      const consumedAt = new Date();
      const [updated] = await transaction("operation_requests")
        .where({ id: row.id, status: "APPROVED" })
        .update({
          status: "CONSUMED",
          consumed_at: consumedAt,
          consumed_by_service: input.serviceName,
          consumption_idempotency_key: input.idempotencyKey,
          updated_at: consumedAt,
        })
        .returning<ApprovalRow[]>("*");
      if (updated === undefined)
        throw new ApiError(
          409,
          "APPROVAL_ALREADY_CONSUMED",
          "Approval was already consumed",
        );
      await transaction("operation_actions").insert({
        operation_request_id: row.id,
        action_type: "CONSUME",
        performed_by: null,
        performed_by_service: input.serviceName,
        status: "CONSUMED",
        action_data: input.binding,
        performed_at: consumedAt,
      });
      await audit(
        transaction,
        updated,
        null,
        "UPDATE",
        input.correlationId,
        input.serviceName,
      );
      return {
        replayed: false,
        result: {
          ...view(updated),
          ...(await approvalEvidence(transaction, updated.id)),
        },
      };
    });
  }

  public reportExecution(input: {
    scope: ApprovalScope;
    tenantId: string | null;
    approvalId: string;
    serviceName: string;
    status: "COMPLETED" | "FAILED";
    result?: Record<string, unknown>;
    errorCode?: string;
    errorMessage?: string;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<{
    replayed: boolean;
    result: {
      approval_id: string;
      execution_status: "COMPLETED" | "FAILED";
      recorded_at: string;
    };
  }> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const row = await findLocked(
        transaction,
        input.approvalId,
        input.scope,
        input.tenantId,
      );
      if (
        row.status !== "CONSUMED" ||
        row.consumed_by_service !== input.serviceName
      )
        throw new ApiError(
          409,
          "APPROVAL_NOT_CONSUMED_BY_SERVICE",
          "Only the consuming service can report execution",
        );
      const existing = await transaction("operation_actions")
        .where({
          operation_request_id: row.id,
          action_type: "EXECUTE",
          performed_by_service: input.serviceName,
        })
        .first<{
          action_data: { idempotency_key?: string };
          status: string;
          performed_at: Date;
        }>();
      if (existing !== undefined) {
        if (
          existing.action_data.idempotency_key !== input.idempotencyKey ||
          existing.status !== input.status
        )
          throw new ApiError(
            409,
            "EXECUTION_ALREADY_RECORDED",
            "Execution result was already recorded",
          );
        return {
          replayed: true,
          result: {
            approval_id: row.id,
            execution_status: input.status,
            recorded_at: existing.performed_at.toISOString(),
          },
        };
      }
      const recordedAt = new Date();
      await transaction("operation_actions").insert({
        operation_request_id: row.id,
        action_type: "EXECUTE",
        performed_by: null,
        performed_by_service: input.serviceName,
        status: input.status,
        action_data: { idempotency_key: input.idempotencyKey },
        result_data: input.result ?? null,
        error_code: input.errorCode ?? null,
        error_message: input.errorMessage ?? null,
        performed_at: recordedAt,
      });
      await transaction("operation_requests")
        .where({ id: row.id })
        .update({
          result_data: input.result ?? null,
          executed_at: recordedAt,
          updated_at: recordedAt,
        });
      return {
        replayed: false,
        result: {
          approval_id: row.id,
          execution_status: input.status,
          recorded_at: recordedAt.toISOString(),
        },
      };
    });
  }

  private async expire(
    approvalId: string,
    scope: ApprovalScope,
    tenantId: string | null,
  ): Promise<void> {
    await withPlatformTransaction(this.database, async (transaction) => {
      const query = transaction("operation_requests")
        .where({ id: approvalId, scope })
        .whereIn("status", ["PENDING", "IN_REVIEW", "APPROVED"])
        .andWhere("expires_at", "<=", transaction.fn.now());
      if (tenantId === null) query.whereNull("tenant_id");
      else query.andWhere("tenant_id", tenantId);
      await query.update({
        status: "EXPIRED",
        decided_at: transaction.fn.now(),
        updated_at: transaction.fn.now(),
      });
    });
  }
}

async function approvalEvidence(
  transaction: Knex.Transaction,
  approvalId: string,
): Promise<{ checker_ids: string[]; approved_authority_level: number }> {
  const approvals = await transaction("operation_approvals")
    .where({ operation_request_id: approvalId, status: "APPROVED" })
    .orderBy("approval_level")
    .select<Array<{ approver_id: string; approval_level: number }>>(
      "approver_id",
      "approval_level",
    );
  if (approvals.length === 0)
    throw new Error("Consumed approval has no checker evidence");
  return {
    checker_ids: approvals.map((approval) => approval.approver_id),
    approved_authority_level: Math.max(
      ...approvals.map((approval) => approval.approval_level),
    ),
  };
}

async function findLocked(
  transaction: Knex.Transaction,
  id: string,
  scope: ApprovalScope,
  tenantId: string | null,
): Promise<ApprovalRow> {
  const query = transaction<ApprovalRow>("operation_requests").where({
    id,
    scope,
  });
  if (tenantId === null) query.whereNull("tenant_id");
  else query.andWhere("tenant_id", tenantId);
  const row = await query.forUpdate().first();
  if (row === undefined)
    throw new ApiError(404, "APPROVAL_NOT_FOUND", "Approval request not found");
  return row;
}

function assertBinding(row: ApprovalRow, binding: ApprovalBinding): void {
  if (
    row.operation_type !== binding.action ||
    row.resource_type !== binding.resourceType ||
    row.resource_id !== binding.resourceId ||
    row.payload_hash !== binding.payloadHash ||
    row.amount_minor !== (binding.amountMinor ?? null) ||
    row.currency !== (binding.currency ?? null)
  )
    throw new ApiError(
      409,
      "APPROVAL_BINDING_MISMATCH",
      "Approval does not match the requested operation",
    );
}

function view(row: ApprovalRow): ApprovalView {
  if (["COMPLETED", "FAILED", "CANCELLED"].includes(row.status))
    throw new Error(`Unsupported approval status ${row.status}`);
  const status = row.status as ApprovalStatus;
  return {
    id: row.id,
    scope: row.scope,
    tenant_id: row.tenant_id,
    action: row.operation_type,
    resource_type: row.resource_type,
    resource_id: row.resource_id,
    payload_hash: row.payload_hash.trim(),
    ...(row.amount_minor === null
      ? {}
      : {
          amount_minor: row.amount_minor,
          currency: row.currency!,
        }),
    required_approvals: row.required_approval_count,
    status,
    maker_id: row.requested_by,
    reason: row.reason,
    expires_at: row.expires_at.toISOString(),
    created_at: row.created_at.toISOString(),
    ...(row.decided_at === null
      ? {}
      : { decided_at: row.decided_at.toISOString() }),
    ...(row.consumed_at === null
      ? {}
      : { consumed_at: row.consumed_at.toISOString() }),
  };
}

async function audit(
  transaction: Knex.Transaction,
  row: ApprovalRow,
  actorId: string | null,
  action: "CREATE" | "UPDATE",
  correlationId: string,
  service?: string,
): Promise<void> {
  await transaction("audit_logs").insert({
    tenant_id: row.tenant_id,
    actor_id: actorId,
    actor_type:
      service === undefined
        ? row.scope === "PLATFORM"
          ? "PLATFORM_ADMIN"
          : "TENANT_ADMIN"
        : "SERVICE",
    action,
    resource_type: "approval_request",
    resource_id: row.id,
    correlation_id: correlationId,
    new_values: { status: row.status },
    metadata: service === undefined ? {} : { service },
  });
}

function replay<T>(record: {
  status: string;
  response_status: number | null;
  response_body: unknown;
}): { replayed: true; result: T } {
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
  return new Date(Date.now() + hours * 3_600_000);
}
