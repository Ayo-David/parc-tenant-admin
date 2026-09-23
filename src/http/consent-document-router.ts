import { randomUUID, timingSafeEqual } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import type { AdministratorAuthorizer } from "../auth/platform-authorizer.js";
import type { ConsentDocumentService } from "../services/consent-document-service.js";
import { ApiError } from "./api-error.js";

const uuid = z.string().uuid();
const consentType = z.enum([
  "TERMS_AND_CONDITIONS",
  "PRIVACY_POLICY",
  "DATA_PROCESSING",
  "KYC",
  "CREDIT_CHECK",
  "MARKETING",
  "BIOMETRIC",
  "OPEN_BANKING",
  "DIRECT_DEBIT",
]);

export function createConsentDocumentRouter(input: {
  service: ConsentDocumentService;
  authorizer: AdministratorAuthorizer;
  serviceToken: string;
}): Router {
  const router = Router();
  router.get("/v1/consent-documents", async (req, res, next) => {
    try {
      const principal = await input.authorizer.authorizeAdministrator(
        bearer(req),
        "configuration.read",
      );
      if (principal.scope !== "TENANT" || !principal.tenantId)
        throw new ApiError(
          403,
          "TENANT_SCOPE_REQUIRED",
          "Tenant administrator scope is required",
        );
      res.json(await input.service.listAll(principal.tenantId));
    } catch (error) {
      next(normalize(error));
    }
  });
  router.post("/v1/consent-documents", async (req, res, next) => {
    try {
      const principal = await input.authorizer.authorizeAdministrator(
        bearer(req),
        "configuration.manage",
      );
      const body = z
        .object({
          tenant_id: uuid,
          consent_type: consentType,
          document_version: z.string().trim().min(1).max(50),
          title: z.string().trim().min(1).max(200),
          purpose: z.string().trim().max(500).optional(),
          channel: z.enum(["MOBILE", "WEB", "ALL"]).default("MOBILE"),
          policy_uri: z.string().url().startsWith("https://"),
          evidence_digest: z.string().regex(/^[0-9a-f]{64}$/),
          required_at_registration: z.boolean().default(false),
          sort_order: z.number().int().nonnegative().default(0),
        })
        .strict()
        .parse(req.body);
      if (principal.scope === "TENANT" && principal.tenantId !== body.tenant_id)
        throw new ApiError(
          403,
          "TENANT_SCOPE_MISMATCH",
          "Tenant administrator cannot manage another tenant's consent catalogue",
        );
      res.status(201).json(
        await input.service.createDraft({
          tenantId: body.tenant_id,
          consentType: body.consent_type,
          documentVersion: body.document_version,
          title: body.title,
          ...(body.purpose ? { purpose: body.purpose } : {}),
          channel: body.channel,
          policyUri: body.policy_uri,
          evidenceDigest: body.evidence_digest,
          requiredAtRegistration: body.required_at_registration,
          sortOrder: body.sort_order,
          actorId: principal.administratorId,
          actorType:
            principal.scope === "TENANT" ? "TENANT_ADMIN" : "PLATFORM_ADMIN",
          idempotencyKey: requiredHeader(req, "idempotency-key"),
          correlationId: req.header("x-correlation-id") ?? randomUUID(),
        }),
      );
    } catch (error) {
      next(normalize(error));
    }
  });
  router.post("/v1/consent-documents/:id/publish", async (req, res, next) => {
    try {
      const principal = await input.authorizer.authorizeAdministrator(
        bearer(req),
        "configuration.publish",
      );
      if (principal.scope !== "TENANT" || !principal.tenantId)
        throw new ApiError(
          403,
          "TENANT_SCOPE_REQUIRED",
          "Tenant administrator scope is required",
        );
      const body = z.object({ approval_id: uuid }).strict().parse(req.body);
      res.json(
        await input.service.publish({
          tenantId: principal.tenantId,
          documentId: uuid.parse(req.params.id),
          approvalId: body.approval_id,
          actorId: principal.administratorId,
          idempotencyKey: requiredHeader(req, "idempotency-key"),
          correlationId: req.header("x-correlation-id") ?? randomUUID(),
        }),
      );
    } catch (error) {
      next(normalize(error));
    }
  });
  router.post(
    "/internal/v1/tenants/:id/consent-documents/validate",
    async (req, res, next) => {
      try {
        serviceAuth(req, input.serviceToken);
        const tenantId = uuid.parse(req.params.id);
        const body = z
          .object({ consent_ids: z.array(uuid).min(1).max(20) })
          .strict()
          .parse(req.body);
        res.json(await input.service.validate(tenantId, body.consent_ids));
      } catch (error) {
        next(normalize(error));
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
function requiredHeader(req: Request, name: string): string {
  const value = req.header(name);
  if (!value)
    throw new ApiError(
      400,
      "IDEMPOTENCY_KEY_REQUIRED",
      "Idempotency-Key is required",
    );
  return value;
}
function serviceAuth(req: Request, expected: string): void {
  const supplied =
    req.header("x-internal-service-token") ??
    req.header("authorization")?.replace(/^Bearer /, "") ??
    "";
  if (
    Buffer.byteLength(supplied) !== Buffer.byteLength(expected) ||
    !timingSafeEqual(Buffer.from(supplied), Buffer.from(expected))
  )
    throw new ApiError(
      401,
      "UNAUTHORIZED_SERVICE",
      "Valid internal service authentication is required",
    );
}
function normalize(error: unknown): ApiError {
  if (error instanceof ApiError) return error;
  if (error instanceof z.ZodError)
    return new ApiError(422, "INVALID_REQUEST", "Request is invalid");
  return new ApiError(500, "INTERNAL_ERROR", "An internal error occurred");
}
