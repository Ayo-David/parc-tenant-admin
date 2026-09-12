import type { Knex } from "knex";

/** Approved TENANT-DB-BILL-01 and TENANT-DB-BILL-02. */
export async function up(knex: Knex): Promise<void> {
  await knex.raw(`
    ALTER TABLE public.provider_capabilities DROP CONSTRAINT provider_capabilities_capability_check;
    ALTER TABLE public.provider_capabilities ADD CONSTRAINT provider_capabilities_capability_check CHECK(capability IN('VIRTUAL_ACCOUNT','COLLECTION','INTERBANK_TRANSFER','DIRECT_DEBIT','BILL_PAYMENT','KYC','EMAIL','SMS','PUSH_NOTIFICATION'));
    ALTER TABLE public.provider_capabilities DROP CONSTRAINT chk_provider_capability_currency;
    ALTER TABLE public.provider_capabilities ADD CONSTRAINT chk_provider_capability_currency CHECK((capability IN('VIRTUAL_ACCOUNT','COLLECTION','INTERBANK_TRANSFER','DIRECT_DEBIT','BILL_PAYMENT') AND currency~'^[A-Z]{3}$') OR (capability IN('KYC','EMAIL','SMS','PUSH_NOTIFICATION') AND currency IS NULL));
    ALTER TABLE public.tenant_provider_selections DROP CONSTRAINT chk_tenant_selection_currency;
    ALTER TABLE public.tenant_provider_selections ADD CONSTRAINT chk_tenant_selection_currency CHECK((capability IN('VIRTUAL_ACCOUNT','COLLECTION','INTERBANK_TRANSFER','DIRECT_DEBIT','BILL_PAYMENT') AND currency~'^[A-Z]{3}$') OR (capability IN('KYC','EMAIL','SMS','PUSH_NOTIFICATION') AND currency IS NULL));
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Bill-payment provider capability is forward-only"),
  );
}
