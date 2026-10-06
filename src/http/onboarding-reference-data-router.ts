import { Router, type Request } from "express";
import { z } from "zod";
import { ApiError } from "./api-error.js";
import {
  requireServiceAccess,
  tenantAdminAccessPolicies,
} from "./service-access.js";
import type { OnboardingReferenceDataService } from "../services/onboarding-reference-data-service.js";

export function createOnboardingReferenceDataRouter(input: {
  service: OnboardingReferenceDataService;
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
  input: { allowedServices: ReadonlySet<string> },
): void {
  requireServiceAccess(
    request,
    tenantAdminAccessPolicies.onboardingReference,
    input.allowedServices,
  );
}
