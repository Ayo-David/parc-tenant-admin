import { createHmac } from "node:crypto";
import argon2 from "argon2";
import type { Knex } from "knex";
import { z } from "zod";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import type { RoleMetadataCache } from "../auth/role-metadata-cache.js";
import { AdministratorRepository } from "../repositories/administrator-repository.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";

type MfaMethod = "TOTP" | "SMS_OTP" | "EMAIL_OTP" | "PASSKEY";

export interface AdministratorVerification {
  administrator_id: string;
  tenant_id: string | null;
  scope: "TENANT" | "PLATFORM";
  status: "ACTIVE" | "SUSPENDED" | "DISABLED";
  roles: string[];
  authorization_version: number;
  mfa_required: true;
  allowed_mfa_methods: MfaMethod[];
}

export interface AdministratorAuthorization {
  roles: string[];
  permissions: string[];
  authorization_version: number;
}

export interface AuthenticationPolicy {
  customer_mfa_required: boolean;
  allowed_customer_mfa_methods: MfaMethod[];
  passkey: null | {
    relying_party_id: string;
    relying_party_name: string;
    allowed_origins: string[];
  };
  version: number;
}

const dummyHash = argon2.hash("tenant-admin-constant-time-placeholder", {
  type: argon2.argon2id,
});
const authenticationPolicySchema = z.object({
  customer_mfa_required: z.boolean(),
  allowed_customer_mfa_methods: z.array(
    z.enum(["TOTP", "SMS_OTP", "EMAIL_OTP", "PASSKEY"]),
  ),
  passkey: z
    .object({
      relying_party_id: z.string().min(1).max(255),
      relying_party_name: z.string().min(1).max(100),
      allowed_origins: z.array(z.string().url()).min(1),
    })
    .nullable(),
  version: z.number().int().positive(),
});

export class AdministratorIdentityService {
  public constructor(
    private readonly database: Knex,
    private readonly idempotencyHashSecret: string,
    private readonly roleCache?: RoleMetadataCache,
  ) {}

  public async verify(input: {
    identifier: string;
    password: string;
    tenantContext: string | null;
    idempotencyKey: string;
  }): Promise<AdministratorVerification> {
    const outcome = await withPlatformTransaction(
      this.database,
      async (transaction) => {
        const idempotency = new IdempotencyRepository(transaction);
        const claim = await idempotency.claim({
          tenantId: input.tenantContext,
          key: `admin-auth:${input.idempotencyKey}`,
          requestHash: createHmac("sha256", this.idempotencyHashSecret)
            .update(JSON.stringify(input))
            .digest("hex"),
          expiresAt: new Date(Date.now() + 5 * 60 * 1000),
        });
        if (!claim.created) {
          if (claim.record.status === "COMPLETED")
            return {
              authenticated: true as const,
              result: claim.record.response_body as AdministratorVerification,
            };
          throw new ApiError(
            409,
            "AUTHENTICATION_IN_PROGRESS",
            "Authentication is in progress",
          );
        }

        const repository = new AdministratorRepository(transaction);
        const administrator = await repository.findForAuthentication(
          input.identifier.trim(),
          input.tenantContext,
        );
        const passwordMatches = await verifyPassword(
          administrator?.password_hash ?? (await dummyHash),
          input.password,
        );
        const now = new Date();
        const active =
          administrator?.status === "ACTIVE" ||
          (administrator?.status === "LOCKED" &&
            administrator.locked_until !== null &&
            administrator.locked_until <= now);
        const usable = administrator !== undefined && passwordMatches && active;
        if (!usable) {
          await repository.recordFailedLogin(
            administrator,
            input.identifier.trim(),
          );
          await transaction("idempotency_keys")
            .where({ id: claim.record.id })
            .delete();
          return { authenticated: false as const };
        }

        const roles = await this.roles(
          repository,
          administrator.id,
          administrator.authorization_version,
        );
        await repository.recordSuccessfulLogin(administrator);
        const result: AdministratorVerification = {
          administrator_id: administrator.id,
          tenant_id: administrator.tenant_id,
          scope: administrator.is_platform_admin ? "PLATFORM" : "TENANT",
          status: "ACTIVE",
          roles,
          authorization_version: administrator.authorization_version,
          mfa_required: true,
          allowed_mfa_methods: ["TOTP", "PASSKEY", "SMS_OTP", "EMAIL_OTP"],
        };
        await idempotency.complete({
          id: claim.record.id,
          responseStatus: 200,
          responseBody: result,
          resourceType: "administrator",
          resourceId: administrator.id,
        });
        return { authenticated: true as const, result };
      },
    );
    if (!outcome.authenticated)
      throw new ApiError(401, "AUTHENTICATION_FAILED", "Authentication failed");
    return outcome.result;
  }

  public getAuthorization(
    administratorId: string,
  ): Promise<AdministratorAuthorization> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const repository = new AdministratorRepository(transaction);
      const administrator = await repository.findById(administratorId);
      if (administrator === undefined)
        throw new ApiError(
          404,
          "ADMINISTRATOR_NOT_FOUND",
          "Administrator not found",
        );
      if (administrator.status !== "ACTIVE")
        throw new ApiError(
          403,
          "ADMINISTRATOR_INACTIVE",
          "Administrator is inactive",
        );
      return {
        roles: await this.roles(
          repository,
          administrator.id,
          administrator.authorization_version,
        ),
        // Permissions are deliberately never cached because they authorize sensitive actions.
        permissions: await repository.getPermissions(administrator.id),
        authorization_version: administrator.authorization_version,
      };
    });
  }

  public getAuthenticationPolicy(
    tenantId: string | null,
  ): Promise<AuthenticationPolicy> {
    return withPlatformTransaction(this.database, async (transaction) => {
      const table =
        tenantId === null ? "system_configurations" : "tenant_configurations";
      if (
        tenantId !== null &&
        (await transaction("tenants")
          .where({ id: tenantId })
          .whereNull("deleted_at")
          .first("id")) === undefined
      )
        throw new ApiError(404, "TENANT_NOT_FOUND", "Tenant not found");
      const query = transaction(table)
        .where({ configuration_key: "authentication.policy" })
        .whereNull("deleted_at")
        .orderBy("version", "desc");
      if (tenantId !== null) query.andWhere("tenant_id", tenantId);
      const row = await query.first<{
        configuration_value: AuthenticationPolicy;
      }>();
      return authenticationPolicySchema.parse(
        row?.configuration_value ?? defaultPolicy(),
      );
    });
  }

  private async roles(
    repository: AdministratorRepository,
    administratorId: string,
    authorizationVersion: number,
  ): Promise<string[]> {
    const cached = await this.roleCache?.get(
      administratorId,
      authorizationVersion,
    );
    if (cached !== undefined) return cached;
    const roles = await repository.getRoles(administratorId);
    await this.roleCache?.set(administratorId, authorizationVersion, roles);
    return roles;
  }
}

async function verifyPassword(
  hash: string,
  password: string,
): Promise<boolean> {
  try {
    return await argon2.verify(hash, password);
  } catch {
    return false;
  }
}

function defaultPolicy(): AuthenticationPolicy {
  return {
    customer_mfa_required: false,
    allowed_customer_mfa_methods: ["TOTP", "SMS_OTP", "EMAIL_OTP", "PASSKEY"],
    passkey: null,
    version: 1,
  };
}
