import type { Knex } from "knex";

/** Approved EDGE-DB-02: tenant-specific, publishable mobile FAQs. */
export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasTable("support_faqs")) return;
  await knex.raw(`
    CREATE TABLE public.support_faqs (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      faq_key uuid NOT NULL DEFAULT gen_random_uuid(),
      tenant_id uuid NOT NULL REFERENCES public.tenants(id),
      category_id uuid REFERENCES public.support_categories(id),
      question text NOT NULL CHECK (length(btrim(question)) BETWEEN 1 AND 500),
      answer text NOT NULL CHECK (length(btrim(answer)) BETWEEN 1 AND 10000),
      version integer NOT NULL DEFAULT 1 CHECK (version > 0),
      sort_order integer NOT NULL DEFAULT 0 CHECK (sort_order >= 0),
      status varchar(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','PUBLISHED','RETIRED')),
      effective_from timestamptz,
      effective_until timestamptz,
      published_at timestamptz,
      created_by uuid REFERENCES public.admin_users(id),
      updated_by uuid REFERENCES public.admin_users(id),
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      deleted_at timestamptz,
      CONSTRAINT chk_support_faq_period CHECK (effective_until IS NULL OR (effective_from IS NOT NULL AND effective_until > effective_from)),
      CONSTRAINT chk_support_faq_publication CHECK (status <> 'PUBLISHED' OR (published_at IS NOT NULL AND effective_from IS NOT NULL)),
      CONSTRAINT uq_support_faq_version UNIQUE (tenant_id, faq_key, version)
    );
    CREATE INDEX idx_support_faq_mobile ON public.support_faqs(tenant_id, sort_order, created_at)
      WHERE status = 'PUBLISHED' AND deleted_at IS NULL;
    ALTER TABLE public.support_faqs ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.support_faqs FORCE ROW LEVEL SECURITY;
    CREATE POLICY support_faq_isolation ON public.support_faqs
      USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id())
      WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
    CREATE OR REPLACE FUNCTION public.protect_published_support_faq() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF OLD.status IN ('PUBLISHED','RETIRED') AND (
        TG_OP = 'DELETE' OR NEW.question IS DISTINCT FROM OLD.question OR
        NEW.answer IS DISTINCT FROM OLD.answer OR NEW.tenant_id IS DISTINCT FROM OLD.tenant_id OR
        NEW.faq_key IS DISTINCT FROM OLD.faq_key OR NEW.version IS DISTINCT FROM OLD.version OR
        NEW.category_id IS DISTINCT FROM OLD.category_id
      ) THEN RAISE EXCEPTION 'published support FAQ versions are immutable' USING ERRCODE='55000'; END IF;
      RETURN COALESCE(NEW, OLD);
    END $$;
    CREATE TRIGGER trg_protect_published_support_faq BEFORE UPDATE OR DELETE ON public.support_faqs
      FOR EACH ROW EXECUTE FUNCTION public.protect_published_support_faq();
    GRANT SELECT,INSERT,UPDATE,DELETE ON public.support_faqs TO parc_tenant_admin_runtime,parc_tenant_admin_platform;
    GRANT SELECT ON public.support_faqs TO parc_tenant_admin_readonly;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(new Error("Support FAQ storage is forward-only"));
}
