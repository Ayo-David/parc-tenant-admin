import type { Knex } from "knex";

/** Approved provider-catalog data update: BankOne remains disabled until activation. */
export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    INSERT INTO public.provider_catalog(provider_code, display_name, category)
    VALUES ('BANKONE', 'BankOne (AppZone) by Qore', 'FINANCIAL')
    ON CONFLICT (provider_code) DO NOTHING;

    INSERT INTO public.provider_capabilities(provider_code, capability, currency)
    VALUES
      ('BANKONE', 'VIRTUAL_ACCOUNT', 'NGN'),
      ('BANKONE', 'COLLECTION', 'NGN'),
      ('BANKONE', 'INTERBANK_TRANSFER', 'NGN')
    ON CONFLICT DO NOTHING;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("BankOne provider registration is forward-only"),
  );
}
