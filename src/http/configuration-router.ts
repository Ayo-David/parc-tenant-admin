import { randomUUID, timingSafeEqual } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import type { AdministratorAuthorizer } from "../auth/platform-authorizer.js";
import type { ConfigurationService } from "../services/configuration-service.js";
import { ApiError } from "./api-error.js";

const uuid = z.string().uuid();
const definition = z
  .object({
    key: z.string().regex(/^[a-z][a-z0-9_.-]{2,199}$/),
    data_type: z.enum(["BOOLEAN", "INTEGER", "DECIMAL", "STRING", "JSON"]),
    validation_schema: z.unknown().optional(),
    is_secret: z.boolean().optional(),
    approval_policy: z.enum(["NONE", "REQUIRED"]).optional(),
    classification: z
      .enum([
        "OPERATIONAL",
        "FINANCIAL",
        "SECURITY",
        "ACCESS",
        "PROVIDER",
        "PRICING",
        "LIMIT",
        "RISK",
      ])
      .optional(),
    description: z.string().max(2000).optional(),
  })
  .strict();
const draft = z
  .object({
    definition_id: uuid,
    scope: z.enum(["SYSTEM", "TIER", "TENANT"]),
    tenant_id: uuid.optional(),
    tier_id: uuid.optional(),
    value: z.unknown(),
    effective_from: z.string().datetime(),
    effective_until: z.string().datetime().optional(),
    reason: z.string().trim().min(3).max(1000),
  })
  .strict();

export function createConfigurationRouter(input: {
  service: ConfigurationService;
  authorizer: AdministratorAuthorizer;
  serviceToken: string;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.post(
    "/v1/platform/configuration-definitions",
    async (req, res, next) => {
      try {
        await input.authorizer.authorize(bearer(req), "configuration.manage");
        const body = definition.parse(req.body);
        res.status(201).json(
          await input.service.createDefinition({
            key: body.key,
            dataType: body.data_type,
            ...(body.validation_schema === undefined
              ? {}
              : { validationSchema: body.validation_schema }),
            ...(body.is_secret === undefined
              ? {}
              : { isSecret: body.is_secret }),
            ...(body.approval_policy === undefined
              ? {}
              : { approvalPolicy: body.approval_policy }),
            ...(body.classification === undefined
              ? {}
              : { classification: body.classification }),
            ...(body.description === undefined
              ? {}
              : { description: body.description }),
            idempotencyKey: idempotency(req),
          }),
        );
      } catch (e) {
        next(normalize(e));
      }
    },
  );
  router.post("/v1/configuration-versions", async (req, res, next) => {
    try {
      const principal = await input.authorizer.authorizeAdministrator(
        bearer(req),
        "configuration.manage",
      );
      const body = draft.parse(req.body);
      if (
        body.scope === "TENANT" &&
        (principal.scope !== "TENANT" || principal.tenantId !== body.tenant_id)
      )
        throw new ApiError(
          403,
          "TENANT_SCOPE_MISMATCH",
          "Tenant administrator scope is required",
        );
      if (body.scope !== "TENANT" && principal.scope !== "PLATFORM")
        throw new ApiError(
          403,
          "PLATFORM_SCOPE_REQUIRED",
          "Platform administrator scope is required",
        );
      res.status(201).json(
        await input.service.createDraft({
          definitionId: body.definition_id,
          scope: body.scope,
          ...(body.tenant_id === undefined ? {} : { tenantId: body.tenant_id }),
          ...(body.tier_id === undefined ? {} : { tierId: body.tier_id }),
          value: body.value,
          effectiveFrom: new Date(body.effective_from),
          ...(body.effective_until === undefined
            ? {}
            : { effectiveUntil: new Date(body.effective_until) }),
          createdBy: principal.administratorId,
          reason: body.reason,
          idempotencyKey: idempotency(req),
        }),
      );
    } catch (e) {
      next(normalize(e));
    }
  });
  router.post(
    "/v1/configuration-versions/:id/publish",
    async (req, res, next) => {
      try {
        const principal = await input.authorizer.authorizeAdministrator(
          bearer(req),
          "configuration.publish",
        );
        const body = z
          .object({
            approval_id: uuid.optional(),
            expected_version: z.number().int().positive(),
          })
          .strict()
          .parse(req.body);
        res.json(
          await input.service.publish({
            versionId: uuid.parse(req.params.id),
            ...(body.approval_id === undefined
              ? {}
              : { approvalId: body.approval_id }),
            publishedBy: principal.administratorId,
            publisherScope: principal.scope,
            publisherTenantId: principal.tenantId,
            idempotencyKey: idempotency(req),
            correlationId: correlation(req),
            expectedVersion: body.expected_version,
          }),
        );
      } catch (e) {
        next(normalize(e));
      }
    },
  );
  router.get(
    "/internal/v1/tenants/:id/configuration",
    async (req, res, next) => {
      try {
        serviceAuth(req, input);
        const keys =
          req.query.keys === undefined
            ? undefined
            : z.string().parse(req.query.keys).split(",").filter(Boolean);
        res.json(await input.service.resolve(uuid.parse(req.params.id), keys));
      } catch (e) {
        next(normalize(e));
      }
    },
  );
  return router;
}
function bearer(req: Request): string {
  const value = req.header("authorization");
  if (!value?.startsWith("Bearer "))
    throw new ApiError(401, "UNAUTHORIZED", "Bearer token is required");
  return value.slice(7);
}
function idempotency(req: Request): string {
  return (
    req.header("idempotency-key") ??
    (() => {
      throw new ApiError(
        400,
        "IDEMPOTENCY_KEY_REQUIRED",
        "Idempotency-Key is required",
      );
    })()
  );
}
function correlation(req: Request): string {
  return req.header("x-correlation-id") ?? randomUUID();
}
function serviceAuth(
  req: Request,
  input: { serviceToken: string; allowedServices: ReadonlySet<string> },
): void {
  const token = req.header("x-internal-service-token") ?? "";
  const service = req.header("x-calling-service") ?? "";
  if (
    !input.allowedServices.has(service) ||
    token.length !== input.serviceToken.length ||
    !timingSafeEqual(Buffer.from(token), Buffer.from(input.serviceToken))
  )
    throw new ApiError(
      401,
      "UNAUTHORIZED_SERVICE",
      "Valid internal service authentication is required",
    );
}
function normalize(error: unknown): ApiError {
  return error instanceof ApiError
    ? error
    : new ApiError(500, "INTERNAL_ERROR", "An internal error occurred");
}
