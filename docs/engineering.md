# Engineering controls

- Use tenant-bound transactions for every tenant-scoped query.
- Platform access is conferred by database role membership, never request data or a GUC.
- Migrations and schema snapshots are forward-only; production corrections use new migrations.
- Financial and external commands require idempotency and transactional outbox writes.
- Inbox uniqueness is `(source_service, event_id)` and processing must acknowledge only after commit.
- Never import another service's source or query another service's database.
