import { Router, type Request, type RequestHandler } from "express";
import { z } from "zod";
import type { AdministratorIdentityService } from "../services/administrator-identity-service.js";
import { ApiError } from "./api-error.js";
import {
  requireServiceAccess,
  tenantAdminAccessPolicies,
} from "./service-access.js";

const uuid = z.string().uuid();
const credentialSchema = z
  .object({
    identifier: z.string().trim().min(3).max(255),
    password: z.string().min(8).max(1024),
    tenant_context: z.string().uuid().nullable(),
  })
  .strict();

export function createInternalAdministratorRouter(input: {
  service: AdministratorIdentityService;
}): Router {
  const router = Router();
  const authenticateService: RequestHandler = (request, _response, next) => {
    try {
      requireServiceAccess(request, tenantAdminAccessPolicies.administrators);
      next();
    } catch (error) {
      next(error);
    }
  };

  router.post(
    "/internal/v1/admin-auth/verify",
    authenticateService,
    async (request, response, next) => {
      try {
        const body = credentialSchema.parse(request.body);
        response.status(200).json(
          await input.service.verify({
            identifier: body.identifier,
            password: body.password,
            tenantContext: body.tenant_context,
            idempotencyKey: requiredIdempotencyKey(request),
          }),
        );
      } catch (error) {
        next(normalizeError(error));
      }
    },
  );

  router.get(
    "/internal/v1/admins/:id/authorization",
    authenticateService,
    async (request, response, next) => {
      try {
        response
          .status(200)
          .json(
            await input.service.getAuthorization(uuid.parse(request.params.id)),
          );
      } catch (error) {
        next(normalizeError(error));
      }
    },
  );

  router.get(
    "/internal/v1/tenants/:id/authentication-policy",
    authenticateService,
    async (request, response, next) => {
      try {
        response
          .status(200)
          .json(
            await input.service.getAuthenticationPolicy(
              uuid.parse(request.params.id),
            ),
          );
      } catch (error) {
        next(normalizeError(error));
      }
    },
  );

  router.get(
    "/internal/v1/platform/authentication-policy",
    authenticateService,
    async (_request, response, next) => {
      try {
        response
          .status(200)
          .json(await input.service.getAuthenticationPolicy(null));
      } catch (error) {
        next(error);
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
