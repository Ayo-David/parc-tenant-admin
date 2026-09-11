import { randomUUID, timingSafeEqual } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import type { AdministratorAuthorizer } from "../auth/platform-authorizer.js";
import type { ProviderSelectionService } from "../services/provider-selection-service.js";
import { ApiError } from "./api-error.js";

const uuid = z.string().uuid();
const capability = z.enum([
  "VIRTUAL_ACCOUNT",
  "COLLECTION",
  "INTERBANK_TRANSFER",
  "DIRECT_DEBIT",
  "KYC",
  "EMAIL",
  "SMS",
  "PUSH_NOTIFICATION",
]);
const selection = z
  .object({
    capability,
    currency: z
      .string()
      .regex(/^[A-Z]{3}$/)
      .nullable(),
    provider: z.string().regex(/^[A-Z0-9_]{2,50}$/),
    approval_id: uuid,
    reason: z.string().trim().min(3).max(1000),
  })
  .strict();

export function createProviderSelectionRouter(input: {
  service: ProviderSelectionService;
  authorizer: AdministratorAuthorizer;
  serviceToken: string;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.get("/v1/provider-catalog", async (request, response, next) => {
    try {
      const principal = await input.authorizer.authorizeAdministrator(
        bearer(request),
        "provider.read",
      );
      const tenantId = tenantHeader(request);
      if (principal.scope !== "TENANT" || principal.tenantId !== tenantId)
        throw new ApiError(
          403,
          "TENANT_SCOPE_MISMATCH",
          "Tenant administrator is required",
        );
      const parsed = z
        .object({
          capability: capability.optional(),
          currency: z
            .string()
            .regex(/^[A-Z]{3}$/)
            .optional(),
        })
        .parse(request.query);
      response.json({
        providers: await input.service.listAvailable(
          parsed.capability,
          parsed.currency,
        ),
      });
    } catch (error) {
      next(normalize(error));
    }
  });
  router.put(
    "/v1/tenants/:id/provider-selection",
    async (request, response, next) => {
      try {
        const principal = await input.authorizer.authorizeAdministrator(
          bearer(request),
          "provider.select",
        );
        const tenantId = uuid.parse(request.params.id);
        if (principal.scope !== "TENANT" || principal.tenantId !== tenantId)
          throw new ApiError(
            403,
            "TENANT_SCOPE_MISMATCH",
            "Tenant administrator is required",
          );
        const body = selection.parse(request.body);
        assertCurrency(body.capability, body.currency);
        const outcome = await input.service.select({
          tenantId,
          capability: body.capability,
          currency: body.currency,
          provider: body.provider,
          approvalId: body.approval_id,
          selectedBy: principal.administratorId,
          reason: body.reason,
          idempotencyKey: idempotency(request),
          correlationId: correlation(request),
        });
        response.setHeader("Idempotent-Replayed", String(outcome.replayed));
        response.json(outcome.result);
      } catch (error) {
        next(normalize(error));
      }
    },
  );
  router.put(
    "/v1/platform/provider-capabilities/:id",
    async (request, response, next) => {
      try {
        const principal = await input.authorizer.authorize(
          bearer(request),
          "provider.catalog.manage",
        );
        const body = z
          .object({
            is_enabled: z.boolean(),
            availability: z.enum(["AVAILABLE", "DEGRADED", "UNAVAILABLE"]),
            approval_id: uuid,
            reason: z.string().trim().min(3).max(1000),
          })
          .strict()
          .parse(request.body);
        response.json(
          await input.service.setAvailability({
            capabilityId: uuid.parse(request.params.id),
            isEnabled: body.is_enabled,
            availability: body.availability,
            approvalId: body.approval_id,
            changedBy: principal.administratorId,
            reason: body.reason,
            idempotencyKey: idempotency(request),
            correlationId: correlation(request),
          }),
        );
      } catch (error) {
        next(normalize(error));
      }
    },
  );
  router.get(
    "/internal/v1/tenants/:id/provider-selection/:capability",
    async (request, response, next) => {
      try {
        authenticateService(request, input);
        const parsedCapability = capability.parse(request.params.capability);
        const currency =
          request.query.currency === undefined
            ? null
            : z
                .string()
                .regex(/^[A-Z]{3}$/)
                .parse(request.query.currency);
        assertCurrency(parsedCapability, currency);
        response.json(
          await input.service.resolve(
            uuid.parse(request.params.id),
            parsedCapability,
            currency,
          ),
        );
      } catch (error) {
        next(normalize(error));
      }
    },
  );
  return router;
}

function assertCurrency(
  value: z.infer<typeof capability>,
  currency: string | null,
): void {
  const financial = [
    "VIRTUAL_ACCOUNT",
    "COLLECTION",
    "INTERBANK_TRANSFER",
    "DIRECT_DEBIT",
  ].includes(value);
  if (financial !== (currency !== null))
    throw new ApiError(
      422,
      "INVALID_CURRENCY_SCOPE",
      financial
        ? "Financial capability requires currency"
        : "This capability is currency-neutral",
    );
}
function bearer(request: Request): string {
  const value = request.header("Authorization");
  if (value === undefined || !value.startsWith("Bearer "))
    throw new ApiError(401, "UNAUTHORIZED", "Bearer token required");
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
      "A valid Idempotency-Key is required",
    );
  return value;
}
function correlation(request: Request): string {
  const value = request.header("X-Correlation-Id");
  return value !== undefined && uuid.safeParse(value).success
    ? value
    : randomUUID();
}
function authenticateService(
  request: Request,
  input: { serviceToken: string; allowedServices: ReadonlySet<string> },
): void {
  const supplied = request.header("X-Service-Token") ?? "";
  if (
    supplied.length !== input.serviceToken.length ||
    !timingSafeEqual(Buffer.from(supplied), Buffer.from(input.serviceToken))
  )
    throw new ApiError(401, "UNAUTHORIZED", "Service authentication failed");
  const service = request.header("X-Service-Name");
  if (service === undefined || !input.allowedServices.has(service))
    throw new ApiError(
      403,
      "SERVICE_NOT_ALLOWED",
      "Calling service is not approved",
    );
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
      "Idempotency key was reused",
    );
  return error;
}
