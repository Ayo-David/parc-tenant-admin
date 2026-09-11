import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasTable("configuration_definitions")) return;
  await knex.raw(`
    CREATE EXTENSION IF NOT EXISTS btree_gist;
    CREATE TABLE public.configuration_definitions (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      configuration_key varchar(200) NOT NULL UNIQUE,
      data_type varchar(30) NOT NULL CHECK (data_type IN ('BOOLEAN','INTEGER','DECIMAL','STRING','JSON')),
      validation_schema jsonb NOT NULL DEFAULT '{}'::jsonb,
      is_secret boolean NOT NULL DEFAULT false,
      approval_policy varchar(20) NOT NULL DEFAULT 'REQUIRED' CHECK (approval_policy IN ('NONE','REQUIRED')),
      classification varchar(30) NOT NULL DEFAULT 'OPERATIONAL' CHECK (classification IN ('OPERATIONAL','FINANCIAL','SECURITY','ACCESS','PROVIDER','PRICING','LIMIT','RISK')),
      description text,
      is_active boolean NOT NULL DEFAULT true,
      created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
    );
    CREATE TABLE public.configuration_versions (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      definition_id uuid NOT NULL REFERENCES public.configuration_definitions(id),
      scope varchar(20) NOT NULL CHECK (scope IN ('SYSTEM','TIER','TENANT')),
      tenant_id uuid REFERENCES public.tenants(id),
      tier_id uuid REFERENCES public.tenant_tiers(id),
      version integer NOT NULL CHECK (version > 0),
      value jsonb NOT NULL,
      status varchar(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','PUBLISHED','SUPERSEDED','RETIRED')),
      effective_from timestamptz NOT NULL DEFAULT now(), effective_until timestamptz,
      approval_id uuid UNIQUE REFERENCES public.operation_requests(id),
      created_by uuid NOT NULL REFERENCES public.admin_users(id),
      published_by uuid REFERENCES public.admin_users(id), published_at timestamptz,
      created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT chk_configuration_scope CHECK ((scope='SYSTEM' AND tenant_id IS NULL AND tier_id IS NULL) OR (scope='TIER' AND tenant_id IS NULL AND tier_id IS NOT NULL) OR (scope='TENANT' AND tenant_id IS NOT NULL AND tier_id IS NULL)),
      CONSTRAINT chk_configuration_period CHECK (effective_until IS NULL OR effective_until > effective_from),
      CONSTRAINT chk_configuration_publication CHECK ((status='PUBLISHED' AND published_by IS NOT NULL AND published_at IS NOT NULL) OR (status <> 'PUBLISHED')),
      CONSTRAINT uq_configuration_version UNIQUE (definition_id, scope, tenant_id, tier_id, version)
    );
    CREATE UNIQUE INDEX uq_configuration_version_scope
      ON public.configuration_versions (definition_id, scope, COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(tier_id, '00000000-0000-0000-0000-000000000000'::uuid), version);
    ALTER TABLE public.configuration_versions ADD CONSTRAINT configuration_published_periods_do_not_overlap
      EXCLUDE USING gist (
        definition_id WITH =,
        scope WITH =,
        COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid) WITH =,
        COALESCE(tier_id, '00000000-0000-0000-0000-000000000000'::uuid) WITH =,
        tstzrange(effective_from, effective_until, '[)') WITH &&
      ) WHERE (status = 'PUBLISHED');
    CREATE INDEX idx_configuration_effective ON public.configuration_versions(definition_id, scope, tenant_id, tier_id, effective_from DESC) WHERE status='PUBLISHED';
    CREATE TABLE public.tenant_configuration_publications (
      tenant_id uuid PRIMARY KEY REFERENCES public.tenants(id),
      configuration_version bigint NOT NULL DEFAULT 0 CHECK (configuration_version >= 0),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    CREATE OR REPLACE FUNCTION public.protect_published_configuration() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF OLD.status IN ('PUBLISHED','SUPERSEDED','RETIRED') AND (TG_OP='DELETE' OR NEW.value IS DISTINCT FROM OLD.value OR NEW.definition_id IS DISTINCT FROM OLD.definition_id OR NEW.scope IS DISTINCT FROM OLD.scope OR NEW.tenant_id IS DISTINCT FROM OLD.tenant_id OR NEW.tier_id IS DISTINCT FROM OLD.tier_id OR NEW.version IS DISTINCT FROM OLD.version OR NEW.effective_from IS DISTINCT FROM OLD.effective_from OR NEW.effective_until IS DISTINCT FROM OLD.effective_until) THEN RAISE EXCEPTION 'published configuration versions are immutable' USING ERRCODE='55000'; END IF;
      RETURN COALESCE(NEW, OLD);
    END $$;
    CREATE TRIGGER trg_protect_published_configuration BEFORE UPDATE OR DELETE ON public.configuration_versions FOR EACH ROW EXECUTE FUNCTION public.protect_published_configuration();
    CREATE OR REPLACE FUNCTION public.validate_configuration_publication() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE policy varchar(20);
    DECLARE request_status varchar(20);
    DECLARE request_action varchar(100);
    DECLARE request_resource_type varchar(100);
    DECLARE request_resource_id uuid;
    BEGIN
      IF NEW.status = 'PUBLISHED' AND (TG_OP = 'INSERT' OR OLD.status <> 'PUBLISHED') THEN
        SELECT approval_policy INTO policy FROM public.configuration_definitions WHERE id = NEW.definition_id;
        IF policy = 'REQUIRED' THEN
          SELECT status, operation_type, resource_type, resource_id INTO request_status, request_action, request_resource_type, request_resource_id FROM public.operation_requests WHERE id = NEW.approval_id;
          IF NEW.approval_id IS NULL OR request_status <> 'CONSUMED' OR request_action <> 'CONFIGURATION_PUBLISH' OR request_resource_type <> 'configuration_version' OR request_resource_id <> NEW.id THEN
            RAISE EXCEPTION 'published configuration version requires a consumed bound approval' USING ERRCODE='23514';
          END IF;
        END IF;
      END IF;
      RETURN NEW;
    END $$;
    CREATE TRIGGER trg_validate_configuration_publication BEFORE INSERT OR UPDATE ON public.configuration_versions FOR EACH ROW EXECUTE FUNCTION public.validate_configuration_publication();
    ALTER TABLE public.configuration_versions ENABLE ROW LEVEL SECURITY; ALTER TABLE public.configuration_versions FORCE ROW LEVEL SECURITY;
    ALTER TABLE public.tenant_configuration_publications ENABLE ROW LEVEL SECURITY; ALTER TABLE public.tenant_configuration_publications FORCE ROW LEVEL SECURITY;
    CREATE POLICY configuration_version_isolation ON public.configuration_versions USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id()) WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
    CREATE POLICY configuration_publication_isolation ON public.tenant_configuration_publications USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id()) WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
    GRANT SELECT ON public.configuration_definitions TO parc_tenant_admin_runtime;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.configuration_definitions TO parc_tenant_admin_platform;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.configuration_versions, public.tenant_configuration_publications TO parc_tenant_admin_runtime, parc_tenant_admin_platform;
  `);
}
export function down(): Promise<never> {
  return Promise.reject(new Error("Versioned configurations are forward-only"));
}
