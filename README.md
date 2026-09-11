# Parc Tenant Admin

Plain Express and strict TypeScript service for tenant lifecycle, administration,
configuration and shared maker-checker approvals. It exclusively owns the
`parc_tenant_admin` database.

## Local development

Requirements: Node 22.21.1, Yarn 1.22.19 and PostgreSQL.

```sh
yarn install --frozen-lockfile
cp .env.example .env
DATABASE_URL=postgresql:///parc_tenant_admin yarn migrate:latest
yarn dev
```

`GET /health` is process liveness. `GET /ready` checks PostgreSQL readiness.
Run `yarn validate` before review.

T-02 exposes public `POST /v1/tenant-applications`, platform-authorized
`POST /v1/tenants`, and platform-authorized
`POST /v1/tenant-applications/{id}/approve`. Privileged routes fail closed when
Auth & Customer public keys are not configured.

T-03 implements service-authenticated administrator credential verification,
authorization lookup, platform/tenant MFA-policy lookup, Argon2id verification,
lockout tracking, and independent RS256 authorization for privileged routes. Set
the same `INTERNAL_SERVICE_TOKEN` in Auth & Customer and configure Auth's public
keys through `AUTH_JWT_PUBLIC_KEYS_JSON`. Auth administrator tokens include both
`admin-bff` and `tenant-admin` audiences.

Database logins must be granted exactly one appropriate `NOLOGIN` group role:
`parc_tenant_admin_runtime`, `parc_tenant_admin_platform`,
`parc_tenant_admin_worker`, or `parc_tenant_admin_readonly`. Tenant requests must
run through `withTenantTransaction`; platform access requires a connection whose
database identity is explicitly a member of the platform role.
