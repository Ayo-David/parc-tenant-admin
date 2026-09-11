# Domain boundary

Tenant Admin owns tenants, administrator identities and roles, tenant settings,
provider selection, immutable configuration versions, commercial rules, support,
audit, and approval state. A domain service remains responsible for validating a
consumed approval and executing its own action. This service never posts money or
queries another service database.

## Tenant lifecycle

Self-service applications and platform-administrator creation both produce a
`PENDING` tenant (exposed as `PENDING_APPROVAL`), profile, status history,
activation operation request, immutable audit entry, and transactional
`tenant.application-submitted.v1` outbox record. Activation requires a different
authorized Parc platform administrator and atomically writes the approval,
status transition, audit trail, and `tenant.activated.v1` event.

## Administrator identity

Tenant Admin owns administrator credential hashes and RBAC assignments but never
issues JWTs. Auth & Customer calls service-authenticated verification and current-
authorization APIs, performs MFA, and issues five-minute administrator tokens.
Tenant Admin independently verifies RS256 signature, issuer, `tenant-admin`
audience, platform scope, MFA evidence, live status, authorization version, and
the required permission before a privileged request. Role names may be cached for
at most 60 seconds; permission decisions are never cached.

## Shared approvals

Tenant and platform administrators create approval requests that immutably bind
the action, resource, payload digest, optional minor-unit amount and ISO currency,
maker, approval threshold, and expiry. Distinct checkers decide under row locks;
the database independently rejects maker-as-checker and duplicate-checker rows.
Approved requests can be consumed once by an allowlisted, authenticated domain
service using the exact binding. A retry with the same service and idempotency key
replays the result; all other re-use is rejected. The consuming domain executes
its own action and reports a terminal execution result back to Tenant Admin.

## Provider routing

The platform catalog contains Paystack, Wema, VerifyMe, Brevo, Termii, and FCM
with capability-level availability. All capabilities are deliberately seeded
disabled and unavailable. Tenant administrators only receive enabled, operational
provider-capability rows and can select one provider per tenant, capability, and
currency. Financial routing is currently NGN-scoped; KYC and notification routing
is currency-neutral. Every selection consumes an exact approval bound to the
canonical change command, creates immutable version history, and emits
`tenant.provider-changed.v1`. Provider secrets remain external references in
`tenant_service_configurations`.

## Versioned configuration

Platform administrators define typed configuration keys and their approval
policy. Consequential classifications require maker-checker publication. Drafts
are immutable after publication, use effective periods that cannot overlap at
the same scope, and resolve deterministically from system default to tenant-tier
default to tenant override. Publishing supersedes the prior scope version,
increments every affected active tenant's monotonic configuration version, and
emits `tenant.configuration-changed.v1` transactionally. Consumers retrieve the
effective non-secret values through the authenticated internal API and invalidate
their caches by tenant configuration version. Sensitive definitions persist only
a vault reference and are excluded from resolved responses.
