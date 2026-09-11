# Runbook

## Migration

Back up production, verify the approved schema hash, run `yarn migrate:status`,
then `yarn migrate:latest` with the migration identity. Migrations are
forward-only: restore a backup for an unrecoverable baseline failure and issue a
reviewed forward-fix migration for deployed changes.

## Health

- `/health`: process health; no dependency traffic.
- `/ready`: PostgreSQL connectivity; remove the instance from service when down.

On shutdown, stop routing traffic, allow in-flight HTTP work to finish, and close
the database pool. Never log credentials or tenant secrets during diagnosis.

## JWT key rotation

Populate `AUTH_JWT_PUBLIC_KEYS_JSON` with base64-encoded SPKI PEM values keyed by
Auth & Customer `kid`. Add the new public key before Auth starts signing with it,
retain the previous key through the maximum token lifetime, then remove it.
Tenant Admin refuses startup in production without a configured public-key set.
