import { Router } from "express";
import type { Knex } from "knex";
import { z } from "zod";
import { withTenantTransaction } from "../database/transaction.js";
import { TenantRepository } from "../repositories/tenant-repository.js";
import { ApiError } from "./api-error.js";
import {
  requireServiceAccess,
  tenantAdminAccessPolicies,
} from "./service-access.js";

/** Lifecycle states mapped onto the contracted `TenantStatus` enumeration. */
const contractStatus: Readonly<Record<string, string>> = {
  PENDING: "PENDING_APPROVAL",
  ACTIVE: "ACTIVE",
  SUSPENDED: "SUSPENDED",
  DEACTIVATED: "CLOSED",
  TERMINATED: "CLOSED",
};

/** `GET /internal/v1/tenants/{id}/status`, used by Auth before issuing tokens. */
export function createTenantStatusRouter(database: Knex): Router {
  const router = Router();
  router.get(
    "/internal/v1/tenants/:id/status",
    async (request, response, next) => {
      try {
        requireServiceAccess(request, tenantAdminAccessPolicies.status);
        const tenantId = z.string().uuid().parse(request.params.id);
        const result = await withTenantTransaction(
          database,
          tenantId,
          async (transaction) => {
            const tenant = await new TenantRepository(transaction).findById(
              tenantId,
            );
            if (!tenant) return undefined;
            const published = await transaction("configuration_versions")
              .where({ tenant_id: tenantId, status: "PUBLISHED" })
              .max<{ max: number | null }>("version as max")
              .first();
            return { tenant, version: published?.max ?? null };
          },
        );
        const status = result && contractStatus[result.tenant.status];
        if (!result || !status)
          throw new ApiError(404, "TENANT_NOT_FOUND", "Tenant was not found");
        response.status(200).json({
          tenant_id: tenantId,
          status,
          // Version 1 is the system baseline when no tenant override is published.
          configuration_version: Math.max(1, Number(result.version ?? 1)),
        });
      } catch (error) {
        next(
          error instanceof z.ZodError
            ? new ApiError(422, "INVALID_REQUEST", "Tenant id is invalid")
            : error,
        );
      }
    },
  );
  return router;
}
