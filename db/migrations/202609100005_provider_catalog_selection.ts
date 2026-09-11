import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasTable("provider_catalog")) {
    await seedCatalog(knex);
    return;
  }
  await knex.raw(`
    CREATE TABLE public.provider_catalog (
      provider_code varchar(50) PRIMARY KEY,
      display_name varchar(100) NOT NULL,
      category varchar(30) NOT NULL CHECK (category IN ('FINANCIAL', 'KYC', 'EMAIL', 'SMS', 'PUSH')),
      is_enabled boolean NOT NULL DEFAULT false,
      availability varchar(20) NOT NULL DEFAULT 'UNAVAILABLE'
        CHECK (availability IN ('AVAILABLE', 'DEGRADED', 'UNAVAILABLE')),
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    COMMENT ON TABLE public.provider_catalog IS
      'Platform-owned provider discovery catalog. Contains no provider credentials.';

    CREATE TABLE public.provider_capabilities (
      provider_code varchar(50) NOT NULL REFERENCES public.provider_catalog(provider_code),
      capability varchar(40) NOT NULL CHECK (capability IN
        ('VIRTUAL_ACCOUNT', 'COLLECTION', 'INTERBANK_TRANSFER', 'DIRECT_DEBIT',
         'KYC', 'EMAIL', 'SMS', 'PUSH_NOTIFICATION')),
      currency char(3),
      is_enabled boolean NOT NULL DEFAULT false,
      availability varchar(20) NOT NULL DEFAULT 'UNAVAILABLE'
        CHECK (availability IN ('AVAILABLE', 'DEGRADED', 'UNAVAILABLE')),
      updated_by uuid REFERENCES public.admin_users(id),
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT chk_provider_capability_currency CHECK (
        (capability IN ('VIRTUAL_ACCOUNT', 'COLLECTION', 'INTERBANK_TRANSFER', 'DIRECT_DEBIT')
          AND currency ~ '^[A-Z]{3}$') OR
        (capability IN ('KYC', 'EMAIL', 'SMS', 'PUSH_NOTIFICATION') AND currency IS NULL)
      )
    );
    CREATE UNIQUE INDEX uq_provider_capability_scope ON public.provider_capabilities
      (provider_code, capability, COALESCE(currency, '---'));
    CREATE INDEX idx_available_provider_capabilities ON public.provider_capabilities
      (capability, currency, provider_code)
      WHERE is_enabled AND availability IN ('AVAILABLE', 'DEGRADED');

    CREATE TABLE public.tenant_provider_selections (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      tenant_id uuid NOT NULL REFERENCES public.tenants(id),
      capability varchar(40) NOT NULL,
      currency char(3),
      provider_code varchar(50) NOT NULL REFERENCES public.provider_catalog(provider_code),
      version integer NOT NULL DEFAULT 1 CHECK (version > 0),
      approval_id uuid NOT NULL UNIQUE REFERENCES public.operation_requests(id),
      selected_by uuid NOT NULL REFERENCES public.admin_users(id),
      reason text NOT NULL,
      selected_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT chk_tenant_selection_currency CHECK (
        (capability IN ('VIRTUAL_ACCOUNT', 'COLLECTION', 'INTERBANK_TRANSFER', 'DIRECT_DEBIT')
          AND currency ~ '^[A-Z]{3}$') OR
        (capability IN ('KYC', 'EMAIL', 'SMS', 'PUSH_NOTIFICATION') AND currency IS NULL)
      )
    );
    CREATE UNIQUE INDEX uq_tenant_provider_selection_scope ON public.tenant_provider_selections
      (tenant_id, capability, COALESCE(currency, '---'));
    CREATE INDEX idx_tenant_provider_resolution ON public.tenant_provider_selections
      (tenant_id, capability, currency);

    CREATE TABLE public.tenant_provider_selection_history (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      selection_id uuid NOT NULL REFERENCES public.tenant_provider_selections(id),
      tenant_id uuid NOT NULL REFERENCES public.tenants(id),
      capability varchar(40) NOT NULL,
      currency char(3),
      previous_provider_code varchar(50),
      provider_code varchar(50) NOT NULL,
      version integer NOT NULL CHECK (version > 0),
      approval_id uuid NOT NULL UNIQUE REFERENCES public.operation_requests(id),
      selected_by uuid NOT NULL REFERENCES public.admin_users(id),
      reason text NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT uq_tenant_provider_history_version UNIQUE (selection_id, version)
    );
    CREATE INDEX idx_tenant_provider_history ON public.tenant_provider_selection_history
      (tenant_id, capability, currency, version DESC);

    CREATE OR REPLACE FUNCTION public.validate_provider_selection() RETURNS trigger
      LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM public.provider_catalog p
        JOIN public.provider_capabilities c ON c.provider_code = p.provider_code
        WHERE p.provider_code = NEW.provider_code AND p.is_enabled
          AND p.availability IN ('AVAILABLE', 'DEGRADED')
          AND c.capability = NEW.capability AND c.currency IS NOT DISTINCT FROM NEW.currency
          AND c.is_enabled AND c.availability IN ('AVAILABLE', 'DEGRADED')
      ) THEN
        RAISE EXCEPTION 'provider capability is unavailable' USING ERRCODE = '23514';
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM public.operation_requests r
        WHERE r.id = NEW.approval_id AND r.tenant_id = NEW.tenant_id
          AND r.scope = 'TENANT' AND r.status = 'CONSUMED'
          AND r.consumed_by_service = 'parc-tenant-admin'
          AND r.operation_type = 'TENANT_PROVIDER_CHANGE'
          AND r.resource_type = 'tenant' AND r.resource_id = NEW.tenant_id
      ) THEN
        RAISE EXCEPTION 'valid consumed provider-change approval required' USING ERRCODE = '23514';
      END IF;
      RETURN NEW;
    END $$;
    CREATE TRIGGER trg_validate_provider_selection BEFORE INSERT OR UPDATE ON public.tenant_provider_selections
      FOR EACH ROW EXECUTE FUNCTION public.validate_provider_selection();

    CREATE OR REPLACE FUNCTION public.protect_provider_history() RETURNS trigger
      LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'provider selection history is immutable' USING ERRCODE = '55000'; END $$;
    CREATE TRIGGER trg_protect_provider_history BEFORE UPDATE OR DELETE ON public.tenant_provider_selection_history
      FOR EACH ROW EXECUTE FUNCTION public.protect_provider_history();

    ALTER TABLE public.tenant_provider_selections ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.tenant_provider_selections FORCE ROW LEVEL SECURITY;
    ALTER TABLE public.tenant_provider_selection_history ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.tenant_provider_selection_history FORCE ROW LEVEL SECURITY;
    CREATE POLICY tenant_provider_selection_isolation ON public.tenant_provider_selections
      USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id())
      WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
    CREATE POLICY tenant_provider_history_isolation ON public.tenant_provider_selection_history
      USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id())
      WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());

    GRANT SELECT ON public.provider_catalog, public.provider_capabilities TO parc_tenant_admin_runtime;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.provider_catalog, public.provider_capabilities TO parc_tenant_admin_platform;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_provider_selections,
      public.tenant_provider_selection_history TO parc_tenant_admin_runtime, parc_tenant_admin_platform;
  `);
  await seedCatalog(knex);
}

async function seedCatalog(knex: Knex): Promise<void> {
  await knex.raw(`
    INSERT INTO public.provider_catalog(provider_code, display_name, category) VALUES
      ('PAYSTACK', 'Paystack', 'FINANCIAL'), ('WEMA', 'Wema Bank', 'FINANCIAL'),
      ('VERIFYME', 'VerifyMe', 'KYC'), ('BREVO', 'Brevo', 'EMAIL'),
      ('TERMII', 'Termii', 'SMS'), ('FCM', 'Firebase Cloud Messaging', 'PUSH')
    ON CONFLICT (provider_code) DO NOTHING;
    INSERT INTO public.provider_capabilities(provider_code, capability, currency) VALUES
      ('PAYSTACK','VIRTUAL_ACCOUNT','NGN'), ('PAYSTACK','COLLECTION','NGN'),
      ('PAYSTACK','INTERBANK_TRANSFER','NGN'), ('PAYSTACK','DIRECT_DEBIT','NGN'),
      ('WEMA','VIRTUAL_ACCOUNT','NGN'), ('WEMA','COLLECTION','NGN'),
      ('WEMA','INTERBANK_TRANSFER','NGN'), ('WEMA','DIRECT_DEBIT','NGN'),
      ('VERIFYME','KYC',NULL), ('BREVO','EMAIL',NULL), ('TERMII','SMS',NULL),
      ('FCM','PUSH_NOTIFICATION',NULL)
    ON CONFLICT DO NOTHING;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Provider catalog controls are forward-only"),
  );
}
