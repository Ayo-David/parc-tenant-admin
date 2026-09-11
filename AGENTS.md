# Tenant Admin service instructions

## Ownership

Own tenant lifecycle, tiers, features and overrides, tenant/system configuration, admin/staff access metadata, revenue-share configuration where designated, and configuration audit history. Own only the `parc_tenant_admin` database.

## Domain rules

- Tenant identity and status are authoritative here; publish changes for other services rather than allowing database reads.
- Configuration must be typed, validated, versioned where necessary, and auditable with actor, reason and before/after values.
- Define deterministic precedence for system defaults, tier defaults and tenant overrides; test that precedence.
- Sensitive configuration values belong in a secrets system, not plaintext database fields.
- Administrative mutations require least-privilege authorization and an immutable audit trail.
- Revenue-share configuration must have effective dates and must not rewrite historical financial results.

## Database and delivery

- Canonical migrations: `db/migrations/`; generated snapshot: `db/schema/current.sql`.
- Preserve tenant-scoped uniqueness, soft-delete semantics and RLS/application tenant checks.
- Update tenant/admin OpenAPI and event contracts with schema changes. Test tenant isolation, feature resolution, audit creation and concurrent configuration updates.
