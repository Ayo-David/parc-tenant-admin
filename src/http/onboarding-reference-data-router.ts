import { timingSafeEqual } from "node:crypto";
import { Router, type Request } from "express";
import { z } from "zod";
import { ApiError } from "./api-error.js";
import type { OnboardingReferenceDataService } from "../services/onboarding-reference-data-service.js";

export function createOnboardingReferenceDataRouter(input: {
  service: OnboardingReferenceDataService;
  serviceToken: string;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.get(
    "/internal/v1/tenants/:tenantId/onboarding-reference-data",
    async (request, response, next) => {
      try {
        authenticate(request, input);
        const tenantId = z.string().uuid().parse(request.params["tenantId"]);
        if (request.header("x-tenant-id") !== tenantId)
          throw new ApiError(
            403,
            "TENANT_MISMATCH",
            "Tenant context does not match path",
          );
        response.json(await input.service.resolve(tenantId));
      } catch (error) {
        next(error);
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
