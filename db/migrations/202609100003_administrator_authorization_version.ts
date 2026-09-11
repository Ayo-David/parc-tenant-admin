import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    ALTER TABLE public.admin_users
      ADD COLUMN IF NOT EXISTS authorization_version integer NOT NULL DEFAULT 1;

    DO $validation$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM public.admin_users
        WHERE ((is_platform_admin AND tenant_id IS NOT NULL)
            OR (NOT is_platform_admin AND tenant_id IS NULL))
      ) THEN
        RAISE EXCEPTION 'Existing administrator rows violate platform/tenant scope integrity';
      END IF;
    END
    $validation$;

    DO $constraints$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.admin_users'::regclass
          AND conname = 'chk_admin_authorization_version'
      ) THEN
        ALTER TABLE public.admin_users
          ADD CONSTRAINT chk_admin_authorization_version
          CHECK (authorization_version > 0) NOT VALID;
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.admin_users'::regclass
          AND conname = 'chk_admin_scope_integrity'
      ) THEN
        ALTER TABLE public.admin_users
          ADD CONSTRAINT chk_admin_scope_integrity
          CHECK ((is_platform_admin AND tenant_id IS NULL)
            OR (NOT is_platform_admin AND tenant_id IS NOT NULL)) NOT VALID;
      END IF;
    END
    $constraints$;

    ALTER TABLE public.admin_users VALIDATE CONSTRAINT chk_admin_authorization_version;
    ALTER TABLE public.admin_users VALIDATE CONSTRAINT chk_admin_scope_integrity;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Administrator authorization-version controls are forward-only"),
  );
}
