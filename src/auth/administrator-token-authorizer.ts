import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { AdministratorRepository } from "../repositories/administrator-repository.js";
import type { ParcAuth, ParcPrincipal } from "../security/parc-service-auth.js";
import type {
  AdministratorAuthorizer,
  AdministratorPrincipal,
  PlatformAuthorizer,
  PlatformPrincipal,
} from "./platform-authorizer.js";

/**
 * Authorizes administrator console calls from delegated tokens issued by Auth
 * for the `parc-tenant-admin` audience and exchanged by the Admin BFF. Auth has
 * already checked the session, MFA-backed authorization version and tenant;
 * Tenant Admin re-reads the administrator's status and fine-grained permission
 * live for every request.
 */
export class AdministratorTokenAuthorizer
  implements PlatformAuthorizer, AdministratorAuthorizer
{
  public constructor(
    private readonly database: Knex,
    private readonly tokens: Pick<ParcAuth, "verify">,
  ) {}

  public async authorize(
    accessToken: string,
    permission: string,
  ): Promise<PlatformPrincipal> {
    const principal = await this.authorizeAdministrator(
      accessToken,
      permission,
    );
    if (principal.scope !== "PLATFORM" || principal.tenantId !== null)
      throw new ApiError(
        403,
        "FORBIDDEN",
        "Platform administrator is required",
      );
    return { administratorId: principal.administratorId };
  }

  public async authorizeAdministrator(
    accessToken: string,
    permission: string,
  ): Promise<AdministratorPrincipal> {
    let token: ParcPrincipal;
    try {
      token = await this.tokens.verify(accessToken);
    } catch {
      throw new ApiError(401, "UNAUTHORIZED", "Access token is invalid");
    }
    if (
      token.kind !== "delegated" ||
      token.subject?.type !== "ADMINISTRATOR" ||
      token.client !== "parc-admin-bff" ||
      !token.scopes.has("tenant.administration")
    )
      throw new ApiError(
        403,
        "FORBIDDEN",
        "An administrator delegation from the Admin BFF is required",
      );
    const administratorId = token.subject.id;
    return withPlatformTransaction(this.database, async (transaction) => {
      const repository = new AdministratorRepository(transaction);
      const administrator = await repository.findById(administratorId);
      if (
        administrator?.status !== "ACTIVE" ||
        (!administrator.is_platform_admin &&
          administrator.tenant_id !== token.tenantId)
      )
        throw new ApiError(
          401,
          "AUTHORIZATION_STALE",
          "Administrator authorization changed",
        );
      const permissions = await repository.getPermissions(administrator.id);
      if (!permissions.includes(permission))
        throw new ApiError(
          403,
          "FORBIDDEN",
          "Administrator permission is required",
        );
      return {
        administratorId: administrator.id,
        tenantId: administrator.tenant_id,
        scope: administrator.is_platform_admin ? "PLATFORM" : "TENANT",
      };
    });
  }
}
