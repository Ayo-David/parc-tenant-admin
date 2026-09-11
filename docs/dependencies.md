# Dependencies

- PostgreSQL: authoritative Tenant Admin store, RLS and inbox/outbox durability.
- Auth & Customer: JWT issuer; integration is through versioned internal APIs/events only.
- RabbitMQ: planned event transport; no broker client is required by T-01.
- Redis: introduced only when a concrete Tenant Admin caching or coordination flow requires it.

T-03 uses Argon2id to verify administrator password hashes and JOSE to validate
Auth & Customer RS256 access tokens. Redis is optional for authorization-version-
keyed role-name caching; permissions and administrator status are always loaded
from PostgreSQL for authorization decisions.
