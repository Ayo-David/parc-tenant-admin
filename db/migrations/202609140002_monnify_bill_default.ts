import type { Knex } from "knex";

/** Approved platform default: Monnify Bills Payment is available unless a tenant overrides it. */
export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    CREATE TABLE IF NOT EXISTS public.provider_defaults (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      capability varchar(40) NOT NULL,
      currency char(3),
      provider_code varchar(50) NOT NULL REFERENCES public.provider_catalog(provider_code),
      version integer NOT NULL DEFAULT 1 CHECK (version > 0),
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT chk_provider_default_currency CHECK (
        (capability IN ('VIRTUAL_ACCOUNT','COLLECTION','INTERBANK_TRANSFER','DIRECT_DEBIT','BILL_PAYMENT')
          AND currency ~ '^[A-Z]{3}$') OR
        (capability IN ('KYC','EMAIL','SMS','PUSH_NOTIFICATION') AND currency IS NULL)
      )
    );
    CREATE UNIQUE INDEX IF NOT EXISTS uq_provider_default_scope ON public.provider_defaults
      (capability, COALESCE(currency, '---'));
    COMMENT ON TABLE public.provider_defaults IS
      'Platform defaults used only when a tenant has no explicit maker-checker-approved selection.';

    INSERT INTO public.provider_catalog(
      provider_code, display_name, category, is_enabled, availability
    ) VALUES ('MONNIFY', 'Monnify', 'FINANCIAL', true, 'AVAILABLE')
    ON CONFLICT (provider_code) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      category = EXCLUDED.category,
      is_enabled = true,
      availability = 'AVAILABLE',
      updated_at = now();

    INSERT INTO public.provider_capabilities(
      provider_code, capability, currency, is_enabled, availability
    ) VALUES ('MONNIFY', 'BILL_PAYMENT', 'NGN', true, 'AVAILABLE')
    ON CONFLICT DO NOTHING;
    UPDATE public.provider_capabilities
      SET is_enabled = true, availability = 'AVAILABLE', updated_at = now()
      WHERE provider_code = 'MONNIFY' AND capability = 'BILL_PAYMENT' AND currency = 'NGN';

    INSERT INTO public.provider_defaults(capability, currency, provider_code)
    VALUES ('BILL_PAYMENT', 'NGN', 'MONNIFY')
    ON CONFLICT DO NOTHING;
    UPDATE public.provider_defaults SET
      provider_code = 'MONNIFY', updated_at = now()
      WHERE capability = 'BILL_PAYMENT' AND currency = 'NGN';

    GRANT SELECT ON public.provider_defaults TO parc_tenant_admin_runtime;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.provider_defaults TO parc_tenant_admin_platform;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(new Error("Monnify provider default is forward-only"));
}
