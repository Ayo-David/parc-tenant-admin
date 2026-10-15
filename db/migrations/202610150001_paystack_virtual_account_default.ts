import type { Knex } from "knex";

/**
 * Platform default: Paystack opens NGN dedicated virtual accounts unless a
 * tenant has its own maker-checker-approved selection. Lets tenants onboard
 * customers before the admin web app (and its approval flow) exists; a tenant
 * override later still wins, since resolution checks selections first.
 */
export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    UPDATE public.provider_catalog
      SET is_enabled = true, availability = 'AVAILABLE', updated_at = now()
      WHERE provider_code = 'PAYSTACK';

    INSERT INTO public.provider_capabilities(
      provider_code, capability, currency, is_enabled, availability
    ) VALUES ('PAYSTACK', 'VIRTUAL_ACCOUNT', 'NGN', true, 'AVAILABLE')
    ON CONFLICT DO NOTHING;
    UPDATE public.provider_capabilities
      SET is_enabled = true, availability = 'AVAILABLE', updated_at = now()
      WHERE provider_code = 'PAYSTACK' AND capability = 'VIRTUAL_ACCOUNT' AND currency = 'NGN';

    INSERT INTO public.provider_defaults(capability, currency, provider_code)
    VALUES ('VIRTUAL_ACCOUNT', 'NGN', 'PAYSTACK')
    ON CONFLICT DO NOTHING;
    UPDATE public.provider_defaults SET
      provider_code = 'PAYSTACK', updated_at = now()
      WHERE capability = 'VIRTUAL_ACCOUNT' AND currency = 'NGN';
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Paystack virtual-account default is forward-only"),
  );
}
