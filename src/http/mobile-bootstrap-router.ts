import { timingSafeEqual } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import type { MobileBootstrapService } from "../services/mobile-bootstrap-service.js";
import { ApiError } from "./api-error.js";

const query = z.object({
  tenant_slug: z.string().regex(/^[a-z0-9][a-z0-9-]{1,62}$/),
  app_version: z.string().min(1).max(40),
  platform: z.enum(["android", "ios"]),
});

export function createMobileBootstrapRouter(input: {
  service: MobileBootstrapService;
  serviceToken: string;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.get(
    "/internal/v1/mobile/bootstrap",
    async (request, response, next) => {
      try {
        authenticate(request, input);
        const parsed = query.parse(request.query);
        response.json(
          await input.service.resolve({
            tenantSlug: parsed.tenant_slug,
            appVersion: parsed.app_version,
            platform: parsed.platform,
          }),
        );
      } catch (error) {
        next(
          error instanceof ApiError
            ? error
            : error instanceof z.ZodError
              ? new ApiError(422, "INVALID_REQUEST", "Request is invalid")
              : error,
        );
      }
    },
  );
  return router;
}

function authenticate(
  request: Request,
  input: { serviceToken: string; allowedServices: ReadonlySet<string> },
): void {
  const token = request.header("x-internal-service-token") ?? "";
  const caller = request.header("x-calling-service") ?? "";
  if (
    !input.allowedServices.has(caller) ||
    Buffer.byteLength(token) !== Buffer.byteLength(input.serviceToken) ||
    !timingSafeEqual(Buffer.from(token), Buffer.from(input.serviceToken))
  )
    throw new ApiError(
      401,
      "UNAUTHORIZED_SERVICE",
      "Valid internal service authentication is required",
    );
}
