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
and lockout tracking. Configure Auth's verification keys through
`AUTH_JWT_PUBLIC_KEYS_JSON` (or `AUTH_JWKS_URL`).

Every call to Tenant Admin carries a short-lived Auth-issued bearer token for
the `parc-tenant-admin` audience. No shared internal secret is accepted.

- `/internal/v1` routes pass through the shared `parc-service-auth` middleware.
  `src/http/service-access.ts` declares which caller, token kind and scope each
  route accepts. Platform-level, tenantless tokens are accepted only for
  platform scopes such as administrator verification and pre-login mobile
  bootstrap.
- Administrator console routes accept delegated tokens exchanged by the Admin
  BFF with scope `tenant.administration`. Tenant Admin re-reads the
  administrator's status and fine-grained permission live on every request.
- `GET /internal/v1/tenants/{id}/status` serves Auth's tenant check before
  token issuance.

`IDEMPOTENCY_HASH_SECRET` keys administrator-credential idempotency
fingerprints. During migration, set it to the previous `INTERNAL_SERVICE_TOKEN`
value so that in-flight replays still match.

Database logins must be granted exactly one appropriate `NOLOGIN` group role:
`parc_tenant_admin_runtime`, `parc_tenant_admin_platform`,
`parc_tenant_admin_worker`, or `parc_tenant_admin_readonly`. Tenant requests must
run through `withTenantTransaction`; platform access requires a connection whose
database identity is explicitly a member of the platform role.
