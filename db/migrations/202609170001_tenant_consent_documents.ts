import type { Knex } from "knex";

/** Approved TADMIN-DB-07: tenant-owned immutable consent-document catalogue. */
export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasTable("tenant_consent_documents")) return;
  await knex.raw(`
    CREATE TABLE public.tenant_consent_documents (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      document_key uuid NOT NULL DEFAULT gen_random_uuid(),
      tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE RESTRICT,
      consent_type varchar(40) NOT NULL CHECK (consent_type IN ('TERMS_AND_CONDITIONS','PRIVACY_POLICY','DATA_PROCESSING','KYC','CREDIT_CHECK','MARKETING','BIOMETRIC','OPEN_BANKING','DIRECT_DEBIT')),
      document_version varchar(50) NOT NULL CHECK (length(btrim(document_version)) BETWEEN 1 AND 50),
      title varchar(200) NOT NULL CHECK (length(btrim(title)) BETWEEN 1 AND 200),
      purpose varchar(500),
      channel varchar(30) NOT NULL DEFAULT 'MOBILE' CHECK (channel IN ('MOBILE','WEB','ALL')),
      policy_uri text NOT NULL CHECK (policy_uri ~ '^https://'),
      evidence_digest char(64) NOT NULL CHECK (evidence_digest ~ '^[0-9a-f]{64}$'),
      status varchar(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','PUBLISHED','RETIRED')),
      required_at_registration boolean NOT NULL DEFAULT false,
      sort_order integer NOT NULL DEFAULT 0 CHECK (sort_order >= 0),
      effective_from timestamptz,
      effective_until timestamptz,
      created_by uuid REFERENCES public.admin_users(id),
      published_by uuid REFERENCES public.admin_users(id),
      approval_id uuid REFERENCES public.operation_requests(id),
      published_at timestamptz,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      deleted_at timestamptz,
      CONSTRAINT uq_tenant_consent_document_version UNIQUE (tenant_id, document_key, document_version),
      CONSTRAINT chk_tenant_consent_period CHECK (effective_until IS NULL OR (effective_from IS NOT NULL AND effective_until > effective_from)),
      CONSTRAINT chk_tenant_consent_publication CHECK (status <> 'PUBLISHED' OR (published_at IS NOT NULL AND effective_from IS NOT NULL AND approval_id IS NOT NULL))
    );
    CREATE UNIQUE INDEX uq_tenant_consent_current ON public.tenant_consent_documents(tenant_id, consent_type, channel)
      WHERE status = 'PUBLISHED' AND deleted_at IS NULL;
    CREATE INDEX idx_tenant_consent_mobile ON public.tenant_consent_documents(tenant_id, required_at_registration DESC, sort_order)
      WHERE status = 'PUBLISHED' AND deleted_at IS NULL;
    ALTER TABLE public.tenant_consent_documents ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.tenant_consent_documents FORCE ROW LEVEL SECURITY;
    CREATE POLICY tenant_consent_document_isolation ON public.tenant_consent_documents
      USING (public.is_platform_admin() OR tenant_id = public.current_tenant_id())
      WITH CHECK (public.is_platform_admin() OR tenant_id = public.current_tenant_id());
    CREATE OR REPLACE FUNCTION public.protect_published_tenant_consent_document() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF OLD.status IN ('PUBLISHED','RETIRED') AND (
        TG_OP = 'DELETE' OR NEW.tenant_id IS DISTINCT FROM OLD.tenant_id OR
        NEW.document_key IS DISTINCT FROM OLD.document_key OR NEW.document_version IS DISTINCT FROM OLD.document_version OR
        NEW.consent_type IS DISTINCT FROM OLD.consent_type OR NEW.title IS DISTINCT FROM OLD.title OR
        NEW.purpose IS DISTINCT FROM OLD.purpose OR NEW.channel IS DISTINCT FROM OLD.channel OR
        NEW.policy_uri IS DISTINCT FROM OLD.policy_uri OR NEW.evidence_digest IS DISTINCT FROM OLD.evidence_digest OR
        NEW.required_at_registration IS DISTINCT FROM OLD.required_at_registration OR NEW.sort_order IS DISTINCT FROM OLD.sort_order OR
        NEW.effective_from IS DISTINCT FROM OLD.effective_from OR NEW.approval_id IS DISTINCT FROM OLD.approval_id
      ) THEN RAISE EXCEPTION 'published consent-document versions are immutable' USING ERRCODE='55000'; END IF;
      RETURN COALESCE(NEW, OLD);
    END $$;
    CREATE TRIGGER trg_protect_published_tenant_consent_document BEFORE UPDATE OR DELETE ON public.tenant_consent_documents
      FOR EACH ROW EXECUTE FUNCTION public.protect_published_tenant_consent_document();
    GRANT SELECT,INSERT,UPDATE,DELETE ON public.tenant_consent_documents TO parc_tenant_admin_runtime,parc_tenant_admin_platform;
    GRANT SELECT ON public.tenant_consent_documents TO parc_tenant_admin_readonly;

    INSERT INTO public.tenant_consent_documents
      (tenant_id, consent_type, document_version, title, purpose, channel, policy_uri, evidence_digest, required_at_registration, sort_order)
    SELECT t.id, standard.consent_type, '1.0', standard.title,
      standard.title || ' required for customer onboarding', 'MOBILE',
      'https://legal.parc.invalid/' || t.id::text || '/' || lower(replace(standard.consent_type, '_', '-')) || '/v1',
      encode(digest('https://legal.parc.invalid/' || t.id::text || '/' || lower(replace(standard.consent_type, '_', '-')) || '/v1', 'sha256'), 'hex'),
      true, standard.sort_order
    FROM public.tenants t
    CROSS JOIN (VALUES
      ('TERMS_AND_CONDITIONS', 'Terms and Conditions', 10),
      ('PRIVACY_POLICY', 'Privacy Policy', 20),
      ('DATA_PROCESSING', 'Data Processing Consent', 30),
      ('KYC', 'KYC and Identity Verification Consent', 40)
    ) AS standard(consent_type, title, sort_order)
    WHERE t.deleted_at IS NULL;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(
    new Error("Tenant consent-document storage is forward-only"),
  );
}
