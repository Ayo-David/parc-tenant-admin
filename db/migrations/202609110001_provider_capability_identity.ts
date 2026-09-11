import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasColumn("provider_capabilities", "id")) return;
  await knex.raw(`
    ALTER TABLE public.provider_capabilities ADD COLUMN id uuid DEFAULT gen_random_uuid();
    UPDATE public.provider_capabilities SET id = gen_random_uuid() WHERE id IS NULL;
    ALTER TABLE public.provider_capabilities ALTER COLUMN id SET NOT NULL;
    ALTER TABLE public.provider_capabilities ADD CONSTRAINT pk_provider_capabilities PRIMARY KEY (id);

    CREATE TABLE public.provider_capability_availability_history (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      provider_capability_id uuid NOT NULL REFERENCES public.provider_capabilities(id),
      provider_code varchar(50) NOT NULL,
      capability varchar(40) NOT NULL,
      currency char(3),
      previous_is_enabled boolean,
      previous_availability varchar(20),
      is_enabled boolean NOT NULL,
      availability varchar(20) NOT NULL CHECK (availability IN ('AVAILABLE','DEGRADED','UNAVAILABLE')),
      approval_id uuid NOT NULL UNIQUE REFERENCES public.operation_requests(id),
      changed_by uuid NOT NULL REFERENCES public.admin_users(id),
      reason text NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    );
    ALTER TABLE public.provider_capability_availability_history ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.provider_capability_availability_history FORCE ROW LEVEL SECURITY;
    CREATE POLICY provider_capability_history_platform_only ON public.provider_capability_availability_history
      USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());
    CREATE OR REPLACE FUNCTION public.protect_provider_capability_history() RETURNS trigger
      LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'provider capability availability history is immutable' USING ERRCODE = '55000'; END $$;
    CREATE TRIGGER trg_protect_provider_capability_history BEFORE UPDATE OR DELETE ON public.provider_capability_availability_history
      FOR EACH ROW EXECUTE FUNCTION public.protect_provider_capability_history();
    GRANT SELECT, INSERT ON public.provider_capability_availability_history TO parc_tenant_admin_platform;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Provider capability identity is forward-only"),
  );
}
