import { randomUUID } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import type { PlatformAuthorizer } from "../auth/platform-authorizer.js";
import type { TenantLifecycleService } from "../services/tenant-lifecycle-service.js";
import { ApiError } from "./api-error.js";

const applicationSchema = z
  .object({
    legal_name: z.string().trim().min(2).max(200),
    contact_email: z.string().trim().email(),
    contact_phone: z.string().regex(/^\+234[789][01][0-9]{8}$/),
  })
  .strict();
const uuid = z.string().uuid();

export function createTenantLifecycleRouter(input: {
  service: TenantLifecycleService;
  authorizer: PlatformAuthorizer;
}): Router {
  const router = Router();
  router.post("/v1/tenants", async (request, response, next) => {
    try {
      const principal = await input.authorizer.authorize(
        bearerToken(request),
        "tenant.create",
      );
      const body = applicationSchema.parse(request.body);
      const outcome = await input.service.submit({
        application: {
          legalName: body.legal_name,
          contactEmail: body.contact_email.toLowerCase(),
          contactPhone: body.contact_phone,
        },
        idempotencyKey: requiredIdempotencyKey(request),
        correlationId: correlationId(request),
        source: "PLATFORM_ADMIN",
        requestedBy: uuid.parse(principal.administratorId),
      });
      response.setHeader("Idempotent-Replayed", String(outcome.replayed));
      response.status(202).json(outcome.result);
    } catch (error) {
      next(normalizeError(error));
    }
  });

  router.post("/v1/tenant-applications", async (request, response, next) => {
    try {
      const body = applicationSchema.parse(request.body);
      const outcome = await input.service.submit({
        application: {
          legalName: body.legal_name,
          contactEmail: body.contact_email.toLowerCase(),
          contactPhone: body.contact_phone,
        },
        idempotencyKey: requiredIdempotencyKey(request),
        correlationId: correlationId(request),
      });
      response.setHeader("Idempotent-Replayed", String(outcome.replayed));
      response.status(202).json(outcome.result);
    } catch (error) {
      next(normalizeError(error));
    }
  });

  router.post(
    "/v1/tenant-applications/:id/approve",
    async (request, response, next) => {
      try {
        const principal = await input.authorizer.authorize(
          bearerToken(request),
          "tenant.application.approve",
        );
        const outcome = await input.service.approve({
          tenantId: uuid.parse(request.params.id),
          administratorId: uuid.parse(principal.administratorId),
          idempotencyKey: requiredIdempotencyKey(request),
          correlationId: correlationId(request),
        });
        response.setHeader("Idempotent-Replayed", String(outcome.replayed));
        response.status(200).json(outcome.result);
      } catch (error) {
        next(normalizeError(error));
      }
    },
  );
  return router;
}

function requiredIdempotencyKey(request: Request): string {
  const value = request.header("Idempotency-Key");
  if (value === undefined || value.length < 1 || value.length > 255)
    throw new ApiError(
      400,
      "INVALID_IDEMPOTENCY_KEY",
      "A valid Idempotency-Key header is required",
    );
  return value;
}

function bearerToken(request: Request): string {
  const authorization = request.header("Authorization");
  if (
    authorization === undefined ||
    !authorization.startsWith("Bearer ") ||
    authorization.length <= 7
  )
    throw new ApiError(
      401,
      "UNAUTHORIZED",
      "A bearer access token is required",
    );
  return authorization.slice(7);
}

function correlationId(request: Request): string {
  const supplied = request.header("X-Correlation-Id");
  return supplied !== undefined && uuid.safeParse(supplied).success
    ? supplied
    : randomUUID();
}

function normalizeError(error: unknown): unknown {
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
