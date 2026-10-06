import type { Request } from "express";
import {
  authorize,
  ParcAuthError,
  principalOf,
  type AccessPolicy,
  type ParcPrincipal,
} from "../security/parc-service-auth.js";
import { ApiError } from "./api-error.js";

/**
 * Tenant Admin internal endpoint permissions. Every `/internal/v1` request has
 * already passed the shared bearer-token middleware; these policies decide
 * which callers, token kinds and scopes each route accepts.
 */
export const tenantAdminAccessPolicies = {
  status: {
    scopes: ["tenant.status.read"],
    kinds: ["service"],
    actors: ["parc-auth-customer"],
  },
  administrators: {
    scopes: ["tenant.administrators.authenticate"],
    kinds: ["service"],
    actors: ["parc-auth-customer"],
  },
  consentValidation: {
    scopes: ["tenant.consent-documents.validate"],
    kinds: ["service"],
  },
  approvals: { scopes: ["tenant.approvals.consume"] },
  configuration: { scopes: ["tenant.configuration.read"] },
  providerSelection: { scopes: ["tenant.provider-selection.read"] },
  mobileBootstrap: {
    scopes: ["tenant.mobile-bootstrap.read"],
    kinds: ["service"],
  },
  onboardingReference: {
    scopes: ["tenant.onboarding-reference.read"],
    kinds: ["service"],
  },
  customerSupportRead: {
    scopes: ["tenant.customer-support.read"],
    kinds: ["delegated"],
    subjectTypes: ["CUSTOMER"],
  },
  customerSupportWrite: {
    scopes: ["tenant.customer-support.write"],
    kinds: ["delegated"],
    subjectTypes: ["CUSTOMER"],
  },
} satisfies Record<string, AccessPolicy>;

/**
 * Authorizes the validated token for one route. `allowedServices` further
 * restricts the acting service where the route is configured with a caller
 * allowlist. Returns the principal; its `client` is the calling service.
 */
export function requireServiceAccess(
  request: Request,
  policy: AccessPolicy,
  allowedServices?: ReadonlySet<string>,
): ParcPrincipal {
  try {
    const principal = principalOf(request);
    authorize(principal, {
      ...policy,
      ...(allowedServices ? { actors: [...allowedServices] } : {}),
    });
    return principal;
  } catch (error) {
    if (error instanceof ParcAuthError)
      throw new ApiError(error.status, error.code, error.message);
    throw error;
  }
}
