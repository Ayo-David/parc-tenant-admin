-- Publishes a tenant's registration consent documents (Terms, Privacy, KYC).
--
-- Run through scripts/seed-consent-documents.sh, which downloads each policy
-- document and passes its SHA-256 as the evidence digest. Connect as the
-- schema owner (MIGRATION_DATABASE_URL). Everything runs in one transaction
-- under the tenant's RLS context, so it cannot touch another tenant's rows.
--
-- Mirrors ConsentDocumentService.createDraft + publish: a draft per document,
-- a consumed tenant-scoped approval bound to the draft's payload hash, the
-- previous published version retired, and an audit row for each change.
-- Re-running with the same version, URI and digest changes nothing.

\set ON_ERROR_STOP on

\if :{?tenant_id} \else \echo 'Missing -v tenant_id' \quit \endif
\if :{?document_version} \else \echo 'Missing -v document_version' \quit \endif
\if :{?terms_url} \else \echo 'Missing -v terms_url' \quit \endif
\if :{?terms_digest} \else \echo 'Missing -v terms_digest' \quit \endif
\if :{?privacy_url} \else \echo 'Missing -v privacy_url' \quit \endif
\if :{?privacy_digest} \else \echo 'Missing -v privacy_digest' \quit \endif
\if :{?kyc_url} \else \echo 'Missing -v kyc_url' \quit \endif
\if :{?kyc_digest} \else \echo 'Missing -v kyc_digest' \quit \endif

BEGIN;

SELECT set_config('app.current_tenant_id', :'tenant_id', true);

CREATE TEMP TABLE consent_seed (
  consent_type     varchar(40) PRIMARY KEY,
  title            varchar(200) NOT NULL,
  purpose          varchar(500) NOT NULL,
  policy_uri       text NOT NULL CHECK (policy_uri ~ '^https://'),
  evidence_digest  char(64) NOT NULL CHECK (evidence_digest ~ '^[0-9a-f]{64}$'),
  sort_order       integer NOT NULL
) ON COMMIT DROP;

INSERT INTO consent_seed VALUES
  ('TERMS_AND_CONDITIONS', 'Terms and Conditions',
   'Terms governing the customer''s use of the tenant''s services', :'terms_url', :'terms_digest', 10),
  ('PRIVACY_POLICY', 'Privacy Policy',
   'How the tenant collects, uses and protects customer data', :'privacy_url', :'privacy_digest', 20),
  ('KYC', 'KYC and Identity Verification Consent',
   'Consent to verify the customer''s identity (NIN/BVN) for KYC', :'kyc_url', :'kyc_digest', 30);

CREATE TEMP TABLE consent_seed_settings ON COMMIT DROP AS
  SELECT :'tenant_id'::uuid AS tenant_id, :'document_version'::varchar(50) AS document_version;

DO $seed$
DECLARE
  settings record;
  doc record;
  maker_id uuid;
  current_doc record;
  draft_id uuid;
  seed_approval_id uuid;
  doc_key uuid;
  correlation uuid := gen_random_uuid();
  binding text;
BEGIN
  SELECT * INTO settings FROM consent_seed_settings;
  IF NOT EXISTS (SELECT 1 FROM public.tenants WHERE id = settings.tenant_id AND deleted_at IS NULL) THEN
    RAISE EXCEPTION 'Tenant % not found (or not visible to this login)', settings.tenant_id;
  END IF;
  IF EXISTS (SELECT 1 FROM consent_seed WHERE split_part(split_part(policy_uri, '://', 2), '/', 1) ~ '(^|\.)invalid(:|$)') THEN
    RAISE EXCEPTION 'Consent policy URIs must reference a published legal document, not an .invalid host';
  END IF;

  INSERT INTO public.admin_users (tenant_id, email, first_name, last_name, status, metadata)
  VALUES (settings.tenant_id, 'consent-publisher-' || settings.tenant_id || '@parc.invalid',
          'Consent', 'Seed Publisher', 'ACTIVE',
          jsonb_build_object('purpose', 'consent-publication', 'seeded_by', 'seed-consent-documents.sql'))
  ON CONFLICT (lower(email::text)) WHERE deleted_at IS NULL DO UPDATE SET status = 'ACTIVE'
  RETURNING id INTO maker_id;

  FOR doc IN SELECT * FROM consent_seed ORDER BY sort_order LOOP
    SELECT * INTO current_doc FROM public.tenant_consent_documents
      WHERE tenant_id = settings.tenant_id AND consent_type = doc.consent_type AND channel = 'MOBILE'
        AND status = 'PUBLISHED' AND deleted_at IS NULL;
    IF FOUND AND current_doc.document_version = settings.document_version
       AND current_doc.policy_uri = doc.policy_uri AND current_doc.evidence_digest = doc.evidence_digest THEN
      RAISE NOTICE '% % already published; unchanged', doc.consent_type, settings.document_version;
      CONTINUE;
    END IF;

    -- A new version of an existing document keeps its document_key.
    SELECT d.document_key INTO doc_key FROM public.tenant_consent_documents d
      WHERE d.tenant_id = settings.tenant_id AND d.consent_type = doc.consent_type AND d.channel = 'MOBILE'
        AND d.deleted_at IS NULL
      ORDER BY d.created_at DESC LIMIT 1;
    doc_key := COALESCE(doc_key, gen_random_uuid());
    IF EXISTS (SELECT 1 FROM public.tenant_consent_documents
               WHERE tenant_id = settings.tenant_id AND document_key = doc_key AND document_version = settings.document_version) THEN
      RAISE EXCEPTION '% version % already exists with a different URI or digest; use a new document_version',
        doc.consent_type, settings.document_version;
    END IF;

    draft_id := gen_random_uuid();
    INSERT INTO public.tenant_consent_documents
      (id, document_key, tenant_id, consent_type, document_version, title, purpose, channel,
       policy_uri, evidence_digest, required_at_registration, sort_order, created_by)
    VALUES (draft_id, doc_key, settings.tenant_id, doc.consent_type, settings.document_version, doc.title,
            doc.purpose, 'MOBILE', doc.policy_uri, doc.evidence_digest, true, doc.sort_order, maker_id);
    INSERT INTO public.audit_logs (tenant_id, actor_id, actor_type, action, resource_type, resource_id, new_values, correlation_id, metadata)
    VALUES (settings.tenant_id, maker_id, 'TENANT_ADMIN', 'CREATE', 'tenant_consent_document', draft_id,
            jsonb_build_object('consent_type', doc.consent_type, 'document_version', settings.document_version,
                               'status', 'DRAFT', 'evidence_digest', doc.evidence_digest),
            correlation, jsonb_build_object('seeded_by', 'seed-consent-documents.sql'));

    -- Same key order and encoding as JSON.stringify in ConsentDocumentService.binding().
    binding := '{"id":' || to_json(draft_id::text)::text
      || ',"tenant_id":' || to_json(settings.tenant_id::text)::text
      || ',"consent_type":' || to_json(doc.consent_type::text)::text
      || ',"document_version":' || to_json(settings.document_version::text)::text
      || ',"policy_uri":' || to_json(doc.policy_uri)::text
      || ',"evidence_digest":' || to_json(doc.evidence_digest::text)::text
      || ',"required_at_registration":true}';
    seed_approval_id := gen_random_uuid();
    INSERT INTO public.operation_requests
      (id, tenant_id, operation_reference, operation_type, resource_type, resource_id, requested_by,
       status, reason, request_data, scope, payload_hash, expires_at, decided_at,
       consumed_at, consumed_by_service, consumption_idempotency_key)
    VALUES (seed_approval_id, settings.tenant_id, 'SEED-CONSENT-' || draft_id, 'CONSENT_DOCUMENT_PUBLISH',
            'tenant_consent_document', draft_id, maker_id, 'CONSUMED',
            'Operator-seeded consent catalogue publication', '{}'::jsonb, 'TENANT',
            encode(digest(binding, 'sha256'), 'hex'), now() + interval '1 day', now(),
            now(), 'parc-tenant-admin', 'seed-consent:' || draft_id);

    UPDATE public.tenant_consent_documents
      SET status = 'RETIRED', effective_until = now(), updated_at = now()
      WHERE tenant_id = settings.tenant_id AND consent_type = doc.consent_type AND channel = 'MOBILE'
        AND status = 'PUBLISHED';
    UPDATE public.tenant_consent_documents
      SET status = 'PUBLISHED', approval_id = seed_approval_id, published_by = maker_id,
          published_at = now(), effective_from = now(), updated_at = now()
      WHERE id = draft_id AND status = 'DRAFT';
    INSERT INTO public.audit_logs (tenant_id, actor_id, actor_type, action, resource_type, resource_id, old_values, new_values, correlation_id, metadata)
    VALUES (settings.tenant_id, maker_id, 'TENANT_ADMIN', 'UPDATE', 'tenant_consent_document', draft_id,
            jsonb_build_object('status', 'DRAFT'),
            jsonb_build_object('status', 'PUBLISHED', 'document_version', settings.document_version,
                               'evidence_digest', doc.evidence_digest),
            correlation, jsonb_build_object('approval_id', seed_approval_id, 'seeded_by', 'seed-consent-documents.sql'));
    RAISE NOTICE '% % published (%)', doc.consent_type, settings.document_version, draft_id;
  END LOOP;
END $seed$;

SELECT consent_type, document_version, status, required_at_registration, policy_uri
FROM public.tenant_consent_documents
WHERE tenant_id = :'tenant_id' AND status = 'PUBLISHED' AND deleted_at IS NULL
ORDER BY sort_order;

COMMIT;
