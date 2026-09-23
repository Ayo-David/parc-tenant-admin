import { randomUUID } from "node:crypto";
import argon2 from "argon2";
import knex, { type Knex } from "knex";
import { exportSPKI, generateKeyPair, importSPKI, SignJWT } from "jose";
import pino from "pino";
import request from "supertest";
import { createApp } from "../../src/app.js";
import { AdministratorJwtAuthorizer } from "../../src/auth/administrator-jwt-authorizer.js";
import { MemoryRoleMetadataCache } from "../../src/auth/role-metadata-cache.js";
import { loadConfig } from "../../src/config/env.js";
import { AdministratorIdentityService } from "../../src/services/administrator-identity-service.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;
const serviceToken = "test-internal-service-token-at-least-32-characters";

describeDatabase("administrator identity and RBAC", () => {
  let database: Knex;
  let identity: AdministratorIdentityService;
  const tenantId = randomUUID();
  const platformAdministratorId = randomUUID();
  const tenantAdministratorId = randomUUID();
  const roleId = randomUUID();
  const permissionIds = [randomUUID(), randomUUID()] as const;
  const createdTenantIds: string[] = [tenantId];
  const idempotencyKeys: string[] = [];

  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    identity = new AdministratorIdentityService(
      database,
      serviceToken,
      new MemoryRoleMetadataCache(30),
    );
    const passwordHash = await argon2.hash("CorrectHorseBatteryStaple!", {
      type: argon2.argon2id,
    });
    await database("tenants").insert({
      id: tenantId,
      tenant_code: `AUTH_${tenantId.replaceAll("-", "").slice(0, 8).toUpperCase()}`,
      legal_name: "Administrator Auth Test Tenant",
      tenant_type: "OTHER",
      status: "ACTIVE",
    });
    await database("admin_users").insert([
      {
        id: platformAdministratorId,
        tenant_id: null,
        email: `platform-${platformAdministratorId}@example.test`,
        first_name: "Platform",
        last_name: "Administrator",
        password_hash: passwordHash,
        status: "ACTIVE",
        is_platform_admin: true,
      },
      {
        id: tenantAdministratorId,
        tenant_id: tenantId,
        email: `tenant-${tenantAdministratorId}@example.test`,
        first_name: "Tenant",
        last_name: "Administrator",
        password_hash: passwordHash,
        status: "ACTIVE",
        is_platform_admin: false,
      },
    ]);
    await database("admin_roles").insert({
      id: roleId,
      tenant_id: null,
      code: `PLATFORM_OPERATOR_${roleId.slice(0, 8)}`,
      name: "Platform operator test role",
      role_type: "PLATFORM",
    });
    await database("admin_permissions").insert([
      {
        id: permissionIds[0],
        resource: "tenant",
        action: "CREATE",
        code: "tenant.create",
      },
      {
        id: permissionIds[1],
        resource: "tenant.application",
        action: "APPROVE",
        code: "tenant.application.approve",
      },
    ]);
    await database("admin_user_roles").insert({
      admin_user_id: platformAdministratorId,
      role_id: roleId,
    });
    await database("admin_role_permissions").insert(
      permissionIds.map((permissionId) => ({
        role_id: roleId,
        permission_id: permissionId,
      })),
    );
  });

  afterAll(async () => {
    await database("idempotency_keys")
      .whereIn("idempotency_key", idempotencyKeys)
      .delete();
    await database("outbox_events")
      .whereIn("tenant_id", createdTenantIds)
      .delete();
    await database("audit_logs")
      .whereIn("tenant_id", createdTenantIds)
      .delete();
    await database("operation_approvals")
      .whereIn(
        "operation_request_id",
        database("operation_requests")
          .select("id")
          .whereIn("tenant_id", createdTenantIds),
      )
      .delete();
    await database("operation_requests")
      .whereIn("tenant_id", createdTenantIds)
      .delete();
    await database("tenant_status_history")
      .whereIn("tenant_id", createdTenantIds)
      .delete();
    await database("tenant_profiles")
      .whereIn("tenant_id", createdTenantIds)
      .delete();
    await database("admin_role_permissions")
      .where({ role_id: roleId })
      .delete();
    await database("admin_user_roles").where({ role_id: roleId }).delete();
    await database("admin_login_attempts")
      .whereIn("admin_user_id", [
        platformAdministratorId,
        tenantAdministratorId,
      ])
      .orWhereIn("email", [
        `platform-${platformAdministratorId}@example.test`,
        `tenant-${tenantAdministratorId}@example.test`,
      ])
      .delete();
    await database("admin_users")
      .whereIn("id", [platformAdministratorId, tenantAdministratorId])
      .delete();
    await database("admin_roles").where({ id: roleId }).delete();
    await database("admin_permissions").whereIn("id", permissionIds).delete();
    await database("tenants").whereIn("id", createdTenantIds).delete();
    await database.destroy();
  });

  function app() {
    return createApp({
      config: loadConfig({ NODE_ENV: "test" }),
      logger: pino({ enabled: false }),
      administratorIdentity: { service: identity, serviceToken },
    });
  }

  it("authenticates generically, requires service auth, and returns current RBAC", async () => {
    const denied = await request(app()).get(
      `/internal/v1/admins/${platformAdministratorId}/authorization`,
    );
    expect(denied.status).toBe(401);

    const key = randomUUID();
    idempotencyKeys.push(`admin-auth:${key}`);
    const verified = await request(app())
      .post("/internal/v1/admin-auth/verify")
      .set("Authorization", `Bearer ${serviceToken}`)
      .set("Idempotency-Key", key)
      .send({
        identifier: `platform-${platformAdministratorId}@example.test`,
        password: "CorrectHorseBatteryStaple!",
        tenant_context: null,
      });
    expect(verified.status).toBe(200);
    expect(verified.body).toMatchObject({
      administrator_id: platformAdministratorId,
      tenant_id: null,
      scope: "PLATFORM",
      authorization_version: 1,
      mfa_required: true,
    });

    const authorization = await request(app())
      .get(`/internal/v1/admins/${platformAdministratorId}/authorization`)
      .set("Authorization", `Bearer ${serviceToken}`);
    expect(authorization.status).toBe(200);
    expect(
      (authorization.body as { permissions: string[] }).permissions,
    ).toHaveLength(2);

    const policy = await request(app())
      .get("/internal/v1/platform/authentication-policy")
      .set("Authorization", `Bearer ${serviceToken}`);
    expect(policy.status).toBe(200);
    expect(policy.body).toMatchObject({
      customer_mfa_required: false,
      version: 1,
    });
  });

  it("does not intercept unrelated internal routes", async () => {
    const response = await request(app()).get("/internal/v1/mobile/bootstrap");
    expect(response.status).toBe(404);
  });

  it("is enumeration-resistant, commits failed attempts, and enforces tenant context", async () => {
    const key = randomUUID();
    const response = await request(app())
      .post("/internal/v1/admin-auth/verify")
      .set("Authorization", `Bearer ${serviceToken}`)
      .set("Idempotency-Key", key)
      .send({
        identifier: `tenant-${tenantAdministratorId}@example.test`,
        password: "wrong-password",
        tenant_context: tenantId,
      });
    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      code: "AUTHENTICATION_FAILED",
      message: "Authentication failed",
    });
    expect(
      await database("admin_login_attempts")
        .where({ admin_user_id: tenantAdministratorId, successful: false })
        .count<{ count: string }>("*")
        .first(),
    ).toEqual({ count: "1" });

    const wrongScope = await request(app())
      .post("/internal/v1/admin-auth/verify")
      .set("Authorization", `Bearer ${serviceToken}`)
      .set("Idempotency-Key", randomUUID())
      .send({
        identifier: `tenant-${tenantAdministratorId}@example.test`,
        password: "CorrectHorseBatteryStaple!",
        tenant_context: null,
      });
    expect(wrongScope.status).toBe(401);
    expect(wrongScope.body).toEqual(response.body);

    for (let attempt = 0; attempt < 4; attempt += 1) {
      const failed = await request(app())
        .post("/internal/v1/admin-auth/verify")
        .set("Authorization", `Bearer ${serviceToken}`)
        .set("Idempotency-Key", randomUUID())
        .send({
          identifier: `tenant-${tenantAdministratorId}@example.test`,
          password: "wrong-password",
          tenant_context: tenantId,
        });
      expect(failed.status).toBe(401);
    }
    expect(
      await database("admin_users")
        .where({ id: tenantAdministratorId })
        .first("status", "failed_login_attempts"),
    ).toEqual({ status: "LOCKED", failed_login_attempts: 5 });
  });

  it("validates RS256 audience, MFA, scope, live authorization version, and permission", async () => {
    const keys = await generateKeyPair("RS256");
    const publicKey = await importSPKI(
      await exportSPKI(keys.publicKey),
      "RS256",
    );
    const authorizer = new AdministratorJwtAuthorizer(
      database,
      "https://auth.parc.invalid",
      "tenant-admin",
      new Map([["test-key", publicKey]]),
    );
    const permission = "tenant.create";
    const token = await new SignJWT({
      tenant_id: null,
      session_id: randomUUID(),
      subject_type: "ADMINISTRATOR",
      scope: "PLATFORM",
      authorization_version: 1,
      authentication_methods: ["PASSWORD", "TOTP", "MFA"],
    })
      .setProtectedHeader({ alg: "RS256", kid: "test-key" })
      .setIssuer("https://auth.parc.invalid")
      .setAudience(["admin-bff", "tenant-admin"])
      .setSubject(platformAdministratorId)
      .setIssuedAt()
      .setExpirationTime("5m")
      .sign(keys.privateKey);
    await expect(authorizer.authorize(token, permission)).resolves.toEqual({
      administratorId: platformAdministratorId,
    });
    await expect(
      authorizer.authorize(token, "tenant.delete"),
    ).rejects.toMatchObject({ status: 403 });

    await database("admin_users")
      .where({ id: platformAdministratorId })
      .increment("authorization_version", 1);
    await expect(authorizer.authorize(token, permission)).rejects.toMatchObject(
      {
        code: "AUTHORIZATION_STALE",
      },
    );
  });

  it("enforces administrator scope integrity in PostgreSQL", async () => {
    await expect(
      database("admin_users").insert({
        tenant_id: tenantId,
        email: `invalid-scope-${randomUUID()}@example.test`,
        first_name: "Invalid",
        last_name: "Scope",
        is_platform_admin: true,
      }),
    ).rejects.toThrow(/chk_admin_scope_integrity/);
  });
});
