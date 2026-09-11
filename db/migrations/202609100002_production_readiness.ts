import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    DO $roles$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_runtime') THEN
        CREATE ROLE parc_tenant_admin_runtime NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_platform') THEN
        CREATE ROLE parc_tenant_admin_platform NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_worker') THEN
        CREATE ROLE parc_tenant_admin_worker NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_readonly') THEN
        CREATE ROLE parc_tenant_admin_readonly NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
    END
    $roles$;

    CREATE OR REPLACE FUNCTION public.is_platform_admin() RETURNS boolean
      LANGUAGE sql STABLE SECURITY INVOKER
      SET search_path = pg_catalog
      AS $$
        SELECT pg_has_role(current_user, 'parc_tenant_admin_platform', 'member')
          OR pg_has_role(current_user, 'parc_tenant_admin_worker', 'member')
      $$;
    COMMENT ON FUNCTION public.is_platform_admin() IS
      'True only for a database identity in the platform or cross-tenant worker role; session settings cannot elevate access.';

    DO $type$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'inbox_status_enum' AND typnamespace = 'public'::regnamespace) THEN
        CREATE TYPE public.inbox_status_enum AS ENUM
          ('RECEIVED', 'PROCESSING', 'PROCESSED', 'FAILED', 'DEAD_LETTER');
      END IF;
    END
    $type$;

    CREATE TABLE IF NOT EXISTS public.inbox_events (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      tenant_id uuid,
      event_id uuid NOT NULL,
      source_service varchar(100) NOT NULL,
      event_type varchar(150) NOT NULL,
      event_version integer NOT NULL DEFAULT 1,
      aggregate_type varchar(100),
      aggregate_id uuid,
      correlation_id uuid,
      causation_id uuid,
      payload jsonb NOT NULL,
      headers jsonb NOT NULL DEFAULT '{}'::jsonb,
      status public.inbox_status_enum NOT NULL DEFAULT 'RECEIVED',
      attempt_count integer NOT NULL DEFAULT 0,
      received_at timestamptz NOT NULL DEFAULT now(),
      processing_started_at timestamptz,
      processed_at timestamptz,
      next_attempt_at timestamptz,
      last_error_code varchar(100),
      last_error_message text,
      CONSTRAINT uq_inbox_source_event UNIQUE (source_service, event_id),
      CONSTRAINT chk_inbox_event_version CHECK (event_version > 0),
      CONSTRAINT chk_inbox_attempt_count CHECK (attempt_count >= 0)
    );
    CREATE INDEX IF NOT EXISTS idx_inbox_pending
      ON public.inbox_events (status, next_attempt_at, received_at)
      WHERE status IN ('RECEIVED', 'FAILED');
    CREATE INDEX IF NOT EXISTS idx_inbox_tenant_received
      ON public.inbox_events (tenant_id, received_at DESC);
    ALTER TABLE public.inbox_events ENABLE ROW LEVEL SECURITY;
    DO $policy$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'inbox_events' AND policyname = 'inbox_isolation') THEN
        CREATE POLICY inbox_isolation ON public.inbox_events
          USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id())
          WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
      END IF;
    END
    $policy$;

    DO $rls$
    DECLARE relation record;
    BEGIN
      FOR relation IN
        SELECT n.nspname, c.relname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relrowsecurity AND c.relkind IN ('r', 'p')
      LOOP
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', relation.nspname, relation.relname);
      END LOOP;
    END
    $rls$;

    REVOKE ALL ON SCHEMA public FROM PUBLIC;
    REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
    REVOKE ALL ON ALL TABLES IN SCHEMA public FROM parc_tenant_admin_runtime,
      parc_tenant_admin_platform, parc_tenant_admin_worker, parc_tenant_admin_readonly;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM parc_tenant_admin_runtime,
      parc_tenant_admin_platform, parc_tenant_admin_worker, parc_tenant_admin_readonly;
    GRANT USAGE ON SCHEMA public TO parc_tenant_admin_runtime, parc_tenant_admin_platform,
      parc_tenant_admin_worker, parc_tenant_admin_readonly;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO parc_tenant_admin_runtime;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO parc_tenant_admin_platform;
    GRANT SELECT, INSERT, UPDATE ON public.inbox_events, public.outbox_events,
      public.outbox_event_attempts TO parc_tenant_admin_worker;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO parc_tenant_admin_readonly;
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO parc_tenant_admin_runtime,
      parc_tenant_admin_platform, parc_tenant_admin_worker;

    DO $runtime_grants$
    DECLARE relation record;
    BEGIN
      FOR relation IN
        SELECT n.nspname, c.relname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relrowsecurity AND c.relkind IN ('r', 'p')
      LOOP
        EXECUTE format(
          'GRANT INSERT, UPDATE, DELETE ON TABLE %I.%I TO parc_tenant_admin_runtime',
          relation.nspname,
          relation.relname
        );
      END LOOP;
    END
    $runtime_grants$;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Tenant Admin production-readiness controls are forward-only"),
  );
}
