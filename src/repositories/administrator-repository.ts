import type { Knex } from "knex";

export interface AdministratorRecord {
  id: string;
  tenant_id: string | null;
  email: string;
  phone_number: string | null;
  password_hash: string | null;
  status: "INVITED" | "ACTIVE" | "SUSPENDED" | "LOCKED" | "DEACTIVATED";
  is_platform_admin: boolean;
  failed_login_attempts: number;
  locked_until: Date | null;
  authorization_version: number;
}

export interface AdministratorAuthorizationRecord {
  administrator: AdministratorRecord;
  roles: string[];
  permissions: string[];
}

export class AdministratorRepository {
  public constructor(private readonly transaction: Knex.Transaction) {}

  public findForAuthentication(
    identifier: string,
    tenantContext: string | null,
  ): Promise<AdministratorRecord | undefined> {
    const query = this.transaction<AdministratorRecord>("admin_users")
      .whereNull("deleted_at")
      .andWhere((builder) => {
        builder
          .whereRaw("lower(email) = lower(?)", [identifier])
          .orWhere("phone_number", identifier);
      });
    if (tenantContext === null)
      query.whereNull("tenant_id").andWhere("is_platform_admin", true);
    else query.where({ tenant_id: tenantContext, is_platform_admin: false });
    return query.forUpdate().first();
  }

  public findById(id: string): Promise<AdministratorRecord | undefined> {
    return this.transaction<AdministratorRecord>("admin_users")
      .where({ id })
      .whereNull("deleted_at")
      .first();
  }

  public async getAuthorization(
    id: string,
  ): Promise<AdministratorAuthorizationRecord | undefined> {
    const administrator = await this.findById(id);
    if (administrator === undefined) return undefined;
    const roles = await this.getRoles(id);
    const permissions = await this.getPermissions(id);
    return { administrator, roles, permissions };
  }

  public async getRoles(id: string): Promise<string[]> {
    const roles = await this.transaction("admin_user_roles as ur")
      .join("admin_roles as r", "r.id", "ur.role_id")
      .where("ur.admin_user_id", id)
      .whereNull("r.deleted_at")
      .andWhere((builder) => {
        builder
          .whereNull("ur.expires_at")
          .orWhere("ur.expires_at", ">", this.transaction.fn.now());
      })
      .distinct<{ code: string }[]>("r.code");
    return roles.map(({ code }) => code).sort();
  }

  public async getPermissions(id: string): Promise<string[]> {
    const permissions = await this.transaction("admin_user_roles as ur")
      .join("admin_roles as r", "r.id", "ur.role_id")
      .join("admin_role_permissions as rp", "rp.role_id", "r.id")
      .join("admin_permissions as p", "p.id", "rp.permission_id")
      .where("ur.admin_user_id", id)
      .whereNull("r.deleted_at")
      .andWhere((builder) => {
        builder
          .whereNull("ur.expires_at")
          .orWhere("ur.expires_at", ">", this.transaction.fn.now());
      })
      .distinct<{ code: string }[]>("p.code");
    return permissions.map(({ code }) => code).sort();
  }

  public async recordFailedLogin(
    administrator: AdministratorRecord | undefined,
    identifier: string,
  ): Promise<void> {
    await this.transaction("admin_login_attempts").insert({
      admin_user_id: administrator?.id ?? null,
      email: identifier.includes("@") ? identifier.toLowerCase() : null,
      successful: false,
      failure_reason: "INVALID_CREDENTIALS",
    });
    if (
      administrator !== undefined &&
      ["ACTIVE", "LOCKED"].includes(administrator.status)
    ) {
      const failures = administrator.failed_login_attempts + 1;
      await this.transaction("admin_users")
        .where({ id: administrator.id })
        .update({
          failed_login_attempts: failures,
          ...(failures >= 5
            ? {
                status: "LOCKED",
                locked_until: new Date(Date.now() + 15 * 60 * 1000),
              }
            : {}),
        });
    }
  }

  public async recordSuccessfulLogin(
    administrator: AdministratorRecord,
  ): Promise<void> {
    await this.transaction("admin_login_attempts").insert({
      admin_user_id: administrator.id,
      email: administrator.email.toLowerCase(),
      successful: true,
    });
    await this.transaction("admin_users")
      .where({ id: administrator.id })
      .update({
        failed_login_attempts: 0,
        locked_until: null,
        status: "ACTIVE",
        last_login_at: this.transaction.fn.now(),
      });
  }
}
