import { randomUUID, timingSafeEqual } from "node:crypto";
import {
  Router,
  type NextFunction,
  type Request,
  type Response,
} from "express";
import { z } from "zod";
import type { AdministratorAuthorizer } from "../auth/platform-authorizer.js";
import type {
  ApprovalScope,
  ApprovalService,
} from "../services/approval-service.js";
import { ApiError } from "./api-error.js";

const uuid = z.string().uuid();
const bindingShape = {
  action: z.string().trim().min(3).max(100),
  resource_type: z.string().trim().min(1).max(100),
  resource_id: uuid,
  payload_hash: z.string().regex(/^[a-f0-9]{64}$/),
  amount_minor: z
    .string()
    .regex(/^(0|[1-9][0-9]*)$/)
    .optional(),
  currency: z
    .string()
    .regex(/^[A-Z]{3}$/)
    .optional(),
};
const binding = z.object(bindingShape).superRefine((value, context) => {
  if ((value.amount_minor === undefined) !== (value.currency === undefined))
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: "amount_minor and currency must be supplied together",
    });
});
const creation = z
  .object({
    ...bindingShape,
    reason: z.string().trim().min(3).max(1000),
    expires_at: z.string().datetime({ offset: true }),
    required_approvals: z.number().int().min(1).max(3).default(1),
  })
  .superRefine((value, context) => {
    if ((value.amount_minor === undefined) !== (value.currency === undefined))
      context.addIssue({
        code: z.ZodIssueCode.custom,
        message: "amount_minor and currency must be supplied together",
      });
  });
const decision = z
  .object({
    decision: z.enum(["APPROVED", "REJECTED"]),
    reason: z.string().trim().min(1).max(1000).optional(),
  })
  .strict();
const execution = z
  .object({
    status: z.enum(["COMPLETED", "FAILED"]),
    result: z.record(z.unknown()).optional(),
    error_code: z.string().max(100).optional(),
    error_message: z.string().max(1000).optional(),
  })
  .strict();

export function createApprovalRouter(input: {
  service: ApprovalService;
  authorizer: AdministratorAuthorizer;
  serviceToken: string;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.post("/v1/approval-requests", (request, response, next) =>
    create(request, response, next, "TENANT", input),
  );
  router.post("/v1/platform/approval-requests", (request, response, next) =>
    create(request, response, next, "PLATFORM", input),
  );
  router.post(
    "/v1/approval-requests/:id/decisions",
    (request, response, next) =>
      decide(request, response, next, "TENANT", input),
  );
  router.post(
    "/v1/platform/approval-requests/:id/decisions",
    (request, response, next) =>
      decide(request, response, next, "PLATFORM", input),
  );
  router.post("/internal/v1/approvals/:id/consume", (request, response, next) =>
    consume(request, response, next, "TENANT", input),
  );
  router.post(
    "/internal/v1/platform/approvals/:id/consume",
    (request, response, next) =>
      consume(request, response, next, "PLATFORM", input),
  );
  router.post(
    "/internal/v1/approvals/:id/execution",
    (request, response, next) =>
      report(request, response, next, "TENANT", input),
  );
  router.post(
    "/internal/v1/platform/approvals/:id/execution",
    (request, response, next) =>
      report(request, response, next, "PLATFORM", input),
  );
  return router;
}

type Dependencies = Parameters<typeof createApprovalRouter>[0];
async function create(
  request: Request,
  response: Response,
  next: NextFunction,
  scope: ApprovalScope,
  input: Dependencies,
): Promise<void> {
  try {
    const principal = await input.authorizer.authorizeAdministrator(
      bearer(request),
      "approval.create",
    );
    assertScope(principal.scope, scope);
    const body = creation.parse(request.body);
    const tenantId = scope === "TENANT" ? tenantHeader(request) : null;
    if (scope === "TENANT" && principal.tenantId !== tenantId)
      throw new ApiError(
        403,
        "TENANT_SCOPE_MISMATCH",
        "Tenant context does not match the administrator",
      );
    const expiresAt = new Date(body.expires_at);
    if (expiresAt.getTime() <= Date.now())
      throw new ApiError(
        422,
        "INVALID_EXPIRY",
        "Approval expiry must be in the future",
      );
    const outcome = await input.service.create({
      scope,
      tenantId,
      makerId: principal.administratorId,
      binding: toBinding(body),
      reason: body.reason,
      expiresAt,
      requiredApprovals: body.required_approvals,
      idempotencyKey: idempotency(request),
      correlationId: correlation(request),
    });
    response.setHeader("Idempotent-Replayed", String(outcome.replayed));
    response.status(201).json(outcome.result);
  } catch (error) {
    next(normalize(error));
  }
}
async function decide(
  request: Request,
  response: Response,
  next: NextFunction,
  scope: ApprovalScope,
  input: Dependencies,
): Promise<void> {
  try {
    const principal = await input.authorizer.authorizeAdministrator(
      bearer(request),
      "approval.decide",
    );
    assertScope(principal.scope, scope);
    const tenantId = scope === "TENANT" ? tenantHeader(request) : null;
    if (scope === "TENANT" && principal.tenantId !== tenantId)
      throw new ApiError(
        403,
        "TENANT_SCOPE_MISMATCH",
        "Tenant context does not match the administrator",
      );
    const body = decision.parse(request.body);
    const outcome = await input.service.decide({
      scope,
      tenantId,
      approvalId: uuid.parse(request.params.id),
      checkerId: principal.administratorId,
      decision: body.decision,
      ...(body.reason === undefined ? {} : { reason: body.reason }),
      idempotencyKey: idempotency(request),
      correlationId: correlation(request),
    });
    response.setHeader("Idempotent-Replayed", String(outcome.replayed));
    response.status(200).json(outcome.result);
  } catch (error) {
    next(normalize(error));
  }
}
async function consume(
  request: Request,
  response: Response,
  next: NextFunction,
  scope: ApprovalScope,
  input: Dependencies,
): Promise<void> {
  try {
    const serviceName = authenticateService(request, input);
    const body = binding.parse(request.body);
    const outcome = await input.service.consume({
      scope,
      tenantId: scope === "TENANT" ? tenantHeader(request) : null,
      approvalId: uuid.parse(request.params.id),
      serviceName,
      binding: toBinding(body),
      idempotencyKey: idempotency(request),
      correlationId: correlation(request),
    });
    response.setHeader("Idempotent-Replayed", String(outcome.replayed));
    response.status(200).json(outcome.result);
  } catch (error) {
    next(normalize(error));
  }
}
async function report(
  request: Request,
  response: Response,
  next: NextFunction,
  scope: ApprovalScope,
  input: Dependencies,
): Promise<void> {
  try {
    const serviceName = authenticateService(request, input);
    const body = execution.parse(request.body);
    const outcome = await input.service.reportExecution({
      scope,
      tenantId: scope === "TENANT" ? tenantHeader(request) : null,
      approvalId: uuid.parse(request.params.id),
      serviceName,
      status: body.status,
      ...(body.result === undefined ? {} : { result: body.result }),
      ...(body.error_code === undefined ? {} : { errorCode: body.error_code }),
      ...(body.error_message === undefined
        ? {}
        : { errorMessage: body.error_message }),
      idempotencyKey: idempotency(request),
      correlationId: correlation(request),
    });
    response.setHeader("Idempotent-Replayed", String(outcome.replayed));
    response.status(200).json(outcome.result);
  } catch (error) {
    next(normalize(error));
  }
}

function toBinding(value: z.infer<typeof binding>) {
  return {
    action: value.action,
    resourceType: value.resource_type,
    resourceId: value.resource_id,
    payloadHash: value.payload_hash,
    ...(value.amount_minor === undefined
      ? {}
      : { amountMinor: value.amount_minor, currency: value.currency! }),
  };
}
function assertScope(actual: ApprovalScope, expected: ApprovalScope): void {
  if (actual !== expected)
    throw new ApiError(
      403,
      "ADMIN_SCOPE_MISMATCH",
      `${expected} administrator is required`,
    );
}
function bearer(request: Request): string {
  const value = request.header("Authorization");
  if (value === undefined || !value.startsWith("Bearer ") || value.length <= 7)
    throw new ApiError(
      401,
      "UNAUTHORIZED",
      "A bearer access token is required",
    );
  return value.slice(7);
}
function tenantHeader(request: Request): string {
  return uuid.parse(request.header("X-Tenant-Id"));
}
function idempotency(request: Request): string {
  const value = request.header("Idempotency-Key");
  if (value === undefined || value.length < 1 || value.length > 255)
    throw new ApiError(
      400,
      "INVALID_IDEMPOTENCY_KEY",
      "A valid Idempotency-Key header is required",
    );
  return value;
}
function correlation(request: Request): string {
  const value = request.header("X-Correlation-Id");
  return value !== undefined && uuid.safeParse(value).success
    ? value
    : randomUUID();
}
function authenticateService(request: Request, input: Dependencies): string {
  const supplied = request.header("X-Service-Token") ?? "";
  const expected = input.serviceToken;
  if (
    supplied.length !== expected.length ||
    !timingSafeEqual(Buffer.from(supplied), Buffer.from(expected))
  )
    throw new ApiError(401, "UNAUTHORIZED", "Service authentication failed");
  const service = request.header("X-Service-Name");
  if (service === undefined || !input.allowedServices.has(service))
    throw new ApiError(
      403,
      "SERVICE_NOT_ALLOWED",
      "Calling service is not approved",
    );
  return service;
}
function normalize(error: unknown): unknown {
  if (error instanceof z.ZodError)
    return new ApiError(
      422,
      "VALIDATION_ERROR",
      "Request validation failed",
      error.flatten(),
    );
  if (
    error instanceof Error &&
    error.message === "IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST"
  )
    return new ApiError(
      409,
      "IDEMPOTENCY_KEY_REUSED",
      "Idempotency key was used for another request",
    );
  return error;
}
