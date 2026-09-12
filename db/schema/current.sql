--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: admin_role_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.admin_role_type_enum AS ENUM (
    'PLATFORM',
    'TENANT'
);


--
-- Name: admin_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.admin_status_enum AS ENUM (
    'INVITED',
    'ACTIVE',
    'SUSPENDED',
    'LOCKED',
    'DEACTIVATED'
);


--
-- Name: audit_action_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.audit_action_enum AS ENUM (
    'CREATE',
    'READ',
    'UPDATE',
    'DELETE',
    'LOGIN',
    'LOGOUT',
    'APPROVE',
    'REJECT',
    'EXECUTE',
    'EXPORT',
    'ASSIGN',
    'REVOKE',
    'SUSPEND',
    'ACTIVATE'
);


--
-- Name: commercial_agreement_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.commercial_agreement_status AS ENUM (
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'ACTIVE',
    'SUSPENDED',
    'EXPIRED',
    'TERMINATED'
);


--
-- Name: configuration_scope_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.configuration_scope_enum AS ENUM (
    'TENANT',
    'SYSTEM'
);


--
-- Name: feature_override_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.feature_override_type_enum AS ENUM (
    'ENABLE',
    'DISABLE',
    'LIMIT',
    'VALUE'
);


--
-- Name: feature_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.feature_status_enum AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'DEPRECATED'
);


--
-- Name: feature_value_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.feature_value_type_enum AS ENUM (
    'BOOLEAN',
    'INTEGER',
    'DECIMAL',
    'STRING',
    'JSON'
);


--
-- Name: fee_bearer_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fee_bearer_type AS ENUM (
    'TENANT',
    'PARC',
    'CUSTOMER',
    'SHARED'
);


--
-- Name: idempotency_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.idempotency_status_enum AS ENUM (
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


--
-- Name: inbox_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.inbox_status_enum AS ENUM (
    'RECEIVED',
    'PROCESSING',
    'PROCESSED',
    'FAILED',
    'DEAD_LETTER'
);


--
-- Name: operation_approval_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.operation_approval_status_enum AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'SKIPPED'
);


--
-- Name: operation_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.operation_status_enum AS ENUM (
    'PENDING',
    'IN_REVIEW',
    'APPROVED',
    'REJECTED',
    'PROCESSING',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
    'EXPIRED',
    'CONSUMED'
);


--
-- Name: outbox_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.outbox_status_enum AS ENUM (
    'PENDING',
    'PROCESSING',
    'PUBLISHED',
    'FAILED',
    'DEAD_LETTER'
);


--
-- Name: permission_action_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permission_action_enum AS ENUM (
    'CREATE',
    'READ',
    'UPDATE',
    'DELETE',
    'APPROVE',
    'REJECT',
    'EXECUTE',
    'EXPORT',
    'ASSIGN',
    'VIEW_SENSITIVE'
);


--
-- Name: platform_revenue_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.platform_revenue_type AS ENUM (
    'LOAN_INTEREST_SHARE',
    'LOAN_ORIGINATION_SHARE',
    'TRANSFER_REVENUE',
    'BILL_PAYMENT_REVENUE',
    'PAYMENT_REVENUE',
    'SAVINGS_REVENUE',
    'PROVIDER_COMMISSION',
    'PLATFORM_FEE',
    'API_USAGE_FEE',
    'SUBSCRIPTION_FEE',
    'OTHER'
);


--
-- Name: platinum_level_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.platinum_level_enum AS ENUM (
    'LEVEL_1',
    'LEVEL_2',
    'LEVEL_3'
);


--
-- Name: reconciliation_exception_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.reconciliation_exception_status_enum AS ENUM (
    'OPEN',
    'UNDER_REVIEW',
    'RESOLVED',
    'IGNORED'
);


--
-- Name: reconciliation_item_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.reconciliation_item_status_enum AS ENUM (
    'MATCHED',
    'UNMATCHED',
    'PARTIAL',
    'EXCEPTION',
    'RESOLVED'
);


--
-- Name: reconciliation_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.reconciliation_status_enum AS ENUM (
    'PENDING',
    'RUNNING',
    'COMPLETED',
    'FAILED',
    'CANCELLED'
);


--
-- Name: revenue_calculation_basis; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.revenue_calculation_basis AS ENUM (
    'LOAN_INTEREST_COLLECTED',
    'LOAN_PRINCIPAL_DISBURSED',
    'LOAN_ORIGINATION_AMOUNT',
    'TRANSACTION_AMOUNT',
    'TRANSACTION_FEE',
    'BILL_PAYMENT_AMOUNT',
    'BILL_PAYMENT_COMMISSION',
    'SAVINGS_INTEREST',
    'SAVINGS_DEPOSIT_AMOUNT',
    'FIXED_DEPOSIT_AMOUNT',
    'PROVIDER_COMMISSION',
    'OTHER'
);


--
-- Name: revenue_calculation_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.revenue_calculation_method AS ENUM (
    'PERCENTAGE',
    'FIXED_AMOUNT',
    'PERCENTAGE_PLUS_FIXED',
    'TIERED'
);


--
-- Name: revenue_rule_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.revenue_rule_status AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'EXPIRED',
    'TERMINATED'
);


--
-- Name: security_event_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.security_event_type_enum AS ENUM (
    'LOGIN_SUCCESS',
    'LOGIN_FAILED',
    'ACCOUNT_LOCKED',
    'ACCOUNT_UNLOCKED',
    'PASSWORD_CHANGED',
    'MFA_ENABLED',
    'MFA_DISABLED',
    'MFA_FAILED',
    'SUSPICIOUS_LOGIN',
    'IP_BLOCKED',
    'TOKEN_REVOKED',
    'PRIVILEGE_ESCALATION',
    'UNAUTHORIZED_ACCESS',
    'SENSITIVE_DATA_ACCESS'
);


--
-- Name: settlement_frequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.settlement_frequency AS ENUM (
    'IMMEDIATE',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'THRESHOLD',
    'MANUAL'
);


--
-- Name: settlement_funding_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.settlement_funding_mode AS ENUM (
    'BANK_TRANSFER',
    'INTERNAL_TRANSFER',
    'SPLIT_AT_SOURCE',
    'NET_SETTLEMENT',
    'MANUAL'
);


--
-- Name: support_ticket_channel_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.support_ticket_channel_enum AS ENUM (
    'IN_APP',
    'EMAIL',
    'PHONE',
    'CHAT',
    'ADMIN_PORTAL',
    'SYSTEM'
);


--
-- Name: support_ticket_priority_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.support_ticket_priority_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT',
    'CRITICAL'
);


--
-- Name: support_ticket_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.support_ticket_status_enum AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'PENDING_CUSTOMER',
    'PENDING_INTERNAL',
    'RESOLVED',
    'CLOSED',
    'REOPENED'
);


--
-- Name: tenant_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tenant_status_enum AS ENUM (
    'PENDING',
    'ACTIVE',
    'SUSPENDED',
    'DEACTIVATED',
    'TERMINATED'
);


--
-- Name: tenant_tier_code_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tenant_tier_code_enum AS ENUM (
    'BASIC',
    'PREMIUM',
    'PLATINUM'
);


--
-- Name: tenant_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tenant_type_enum AS ENUM (
    'MFB',
    'BANK',
    'FINTECH',
    'COOPERATIVE',
    'MICROFINANCE_INSTITUTION',
    'OTHER'
);


--
-- Name: capture_revenue_settlement_config_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.capture_revenue_settlement_config_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_version INTEGER; v_action VARCHAR(50);
BEGIN
    SELECT COALESCE(MAX(version_number),0)+1 INTO v_version FROM tenant_revenue_settlement_configuration_history WHERE settlement_configuration_id=NEW.id;
    v_action := CASE WHEN TG_OP='INSERT' THEN 'CREATED' WHEN OLD.is_active=FALSE AND NEW.is_active=TRUE THEN 'ACTIVATED' WHEN OLD.is_active=TRUE AND NEW.is_active=FALSE THEN 'DEACTIVATED' ELSE 'UPDATED' END;
    INSERT INTO tenant_revenue_settlement_configuration_history(tenant_id,settlement_configuration_id,version_number,action,snapshot,changed_by) VALUES(NEW.tenant_id,NEW.id,v_version,v_action,to_jsonb(NEW),COALESCE(NEW.updated_by,NEW.created_by));
    RETURN NEW;
END $$;


--
-- Name: capture_revenue_share_rule_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.capture_revenue_share_rule_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_version INTEGER; v_action VARCHAR(50);
BEGIN
    SELECT COALESCE(MAX(version_number),0)+1 INTO v_version FROM tenant_revenue_share_rule_history WHERE revenue_share_rule_id=NEW.id;
    v_action := CASE WHEN TG_OP='INSERT' THEN 'CREATED' WHEN OLD.status IS DISTINCT FROM NEW.status AND NEW.status='ACTIVE' THEN 'ACTIVATED' WHEN OLD.status IS DISTINCT FROM NEW.status AND NEW.status='SUSPENDED' THEN 'SUSPENDED' WHEN OLD.status IS DISTINCT FROM NEW.status AND NEW.status='EXPIRED' THEN 'EXPIRED' WHEN OLD.status IS DISTINCT FROM NEW.status AND NEW.status='TERMINATED' THEN 'TERMINATED' ELSE 'UPDATED' END;
    INSERT INTO tenant_revenue_share_rule_history(tenant_id,revenue_share_rule_id,version_number,action,snapshot,changed_by) VALUES(NEW.tenant_id,NEW.id,v_version,v_action,to_jsonb(NEW),COALESCE(NEW.updated_by,NEW.created_by));
    RETURN NEW;
END $$;


--
-- Name: current_tenant_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_tenant_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
SELECT NULLIF(current_setting('app.current_tenant_id', true),'')::uuid;
$$;


--
-- Name: FUNCTION current_tenant_id(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.current_tenant_id() IS 'Application must set session setting app.current_tenant_id to enforce RLS. Use: SET app.current_tenant_id = ''<uuid>'';';


--
-- Name: decrypt_secret(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.decrypt_secret(cipher bytea) RETURNS text
    LANGUAGE sql STABLE
    AS $$
SELECT pgp_sym_decrypt(cipher, current_setting('app.secrets_key'));
$$;


--
-- Name: encrypt_secret(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.encrypt_secret(plain text) RETURNS bytea
    LANGUAGE sql STABLE
    AS $$
SELECT pgp_sym_encrypt(plain, current_setting('app.secrets_key'))::bytea;
$$;


--
-- Name: enforce_maker_checker(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_maker_checker() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
    BEGIN
      IF EXISTS (SELECT 1 FROM public.operation_requests r
                 WHERE r.id = NEW.operation_request_id AND r.requested_by = NEW.approver_id) THEN
        RAISE EXCEPTION 'maker cannot approve own request' USING ERRCODE = '23514';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: enforce_operation_binding_immutability(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_operation_binding_immutability() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
    BEGIN
      IF ROW(NEW.scope, NEW.tenant_id, NEW.operation_type, NEW.resource_type, NEW.resource_id,
             NEW.requested_by, NEW.payload_hash, NEW.amount_minor, NEW.currency, NEW.expires_at,
             NEW.required_approval_count)
         IS DISTINCT FROM
         ROW(OLD.scope, OLD.tenant_id, OLD.operation_type, OLD.resource_type, OLD.resource_id,
             OLD.requested_by, OLD.payload_hash, OLD.amount_minor, OLD.currency, OLD.expires_at,
             OLD.required_approval_count) THEN
        RAISE EXCEPTION 'approval binding is immutable' USING ERRCODE = '23514';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: is_platform_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_platform_admin() RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog'
    AS $$
        SELECT pg_has_role(current_user, 'parc_tenant_admin_platform', 'member')
          OR pg_has_role(current_user, 'parc_tenant_admin_worker', 'member')
      $$;


--
-- Name: FUNCTION is_platform_admin(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.is_platform_admin() IS 'True only for a database identity in the platform or cross-tenant worker role; session settings cannot elevate access.';


--
-- Name: protect_active_revenue_share_terms(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_active_revenue_share_terms() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.status='ACTIVE' AND (
        NEW.revenue_type IS DISTINCT FROM OLD.revenue_type OR
        NEW.calculation_basis IS DISTINCT FROM OLD.calculation_basis OR
        NEW.calculation_method IS DISTINCT FROM OLD.calculation_method OR
        NEW.percentage_rate IS DISTINCT FROM OLD.percentage_rate OR
        NEW.fixed_amount IS DISTINCT FROM OLD.fixed_amount OR
        NEW.currency_code IS DISTINCT FROM OLD.currency_code OR
        NEW.minimum_revenue_amount IS DISTINCT FROM OLD.minimum_revenue_amount OR
        NEW.maximum_revenue_amount IS DISTINCT FROM OLD.maximum_revenue_amount OR
        NEW.minimum_source_amount IS DISTINCT FROM OLD.minimum_source_amount OR
        NEW.maximum_source_amount IS DISTINCT FROM OLD.maximum_source_amount OR
        NEW.effective_from IS DISTINCT FROM OLD.effective_from OR
        NEW.product_code IS DISTINCT FROM OLD.product_code OR
        NEW.channel_code IS DISTINCT FROM OLD.channel_code OR
        NEW.provider_code IS DISTINCT FROM OLD.provider_code
    ) THEN
        RAISE EXCEPTION 'Economic terms of an ACTIVE revenue-share rule are immutable. End-date the rule and create a new version.';
    END IF;
    RETURN NEW;
END $$;


--
-- Name: protect_provider_capability_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_provider_capability_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'provider capability availability history is immutable' USING ERRCODE = '55000'; END $$;


--
-- Name: protect_provider_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_provider_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'provider selection history is immutable' USING ERRCODE = '55000'; END $$;


--
-- Name: protect_published_configuration(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_published_configuration() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF OLD.status IN ('PUBLISHED','SUPERSEDED','RETIRED') AND (TG_OP='DELETE' OR NEW.value IS DISTINCT FROM OLD.value OR NEW.definition_id IS DISTINCT FROM OLD.definition_id OR NEW.scope IS DISTINCT FROM OLD.scope OR NEW.tenant_id IS DISTINCT FROM OLD.tenant_id OR NEW.tier_id IS DISTINCT FROM OLD.tier_id OR NEW.version IS DISTINCT FROM OLD.version OR NEW.effective_from IS DISTINCT FROM OLD.effective_from OR NEW.effective_until IS DISTINCT FROM OLD.effective_until) THEN RAISE EXCEPTION 'published configuration versions are immutable' USING ERRCODE='55000'; END IF;
      RETURN COALESCE(NEW, OLD);
    END $$;


--
-- Name: purge_old_audit_logs(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.purge_old_audit_logs(retention_days integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM audit_logs WHERE created_at < (now() - (retention_days || ' days')::interval);
END;
$$;


--
-- Name: purge_old_outbox_events(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.purge_old_outbox_events(retention_days integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM outbox_events WHERE created_at < (now() - (retention_days || ' days')::interval)
    AND status = 'PUBLISHED';
END;
$$;


--
-- Name: set_revenue_config_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_revenue_config_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END $$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = transaction_timestamp();
    RETURN NEW;
END;
$$;


--
-- Name: validate_configuration_publication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_configuration_publication() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: validate_provider_selection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_provider_selection() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
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


--
-- Name: validate_revenue_rule_agreement_tenant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_revenue_rule_agreement_tenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_tenant UUID;
BEGIN
    IF NEW.agreement_id IS NULL THEN RETURN NEW; END IF;
    SELECT tenant_id INTO v_tenant FROM tenant_commercial_agreements WHERE id=NEW.agreement_id AND deleted_at IS NULL;
    IF v_tenant IS NULL OR v_tenant <> NEW.tenant_id THEN RAISE EXCEPTION 'Revenue-share rule tenant does not match agreement tenant.'; END IF;
    RETURN NEW;
END $$;


--
-- Name: validate_revenue_share_tier_tenant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_revenue_share_tier_tenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_tenant UUID; v_method revenue_calculation_method;
BEGIN
    SELECT tenant_id, calculation_method INTO v_tenant, v_method FROM tenant_revenue_share_rules WHERE id=NEW.revenue_share_rule_id AND deleted_at IS NULL;
    IF v_tenant IS NULL OR v_tenant <> NEW.tenant_id THEN RAISE EXCEPTION 'Revenue-share tier tenant does not match parent rule tenant.'; END IF;
    IF v_method <> 'TIERED' THEN RAISE EXCEPTION 'Revenue-share tiers may only be attached to TIERED rules.'; END IF;
    RETURN NEW;
END $$;


--
-- Name: validate_settlement_config_agreement_tenant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_settlement_config_agreement_tenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_tenant UUID;
BEGIN
    IF NEW.agreement_id IS NULL THEN RETURN NEW; END IF;
    SELECT tenant_id INTO v_tenant FROM tenant_commercial_agreements WHERE id=NEW.agreement_id AND deleted_at IS NULL;
    IF v_tenant IS NULL OR v_tenant <> NEW.tenant_id THEN RAISE EXCEPTION 'Settlement configuration tenant does not match agreement tenant.'; END IF;
    RETURN NEW;
END $$;


--
-- Name: verify_tenant_referential_integrity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verify_tenant_referential_integrity() RETURNS TABLE(table_name text, missing_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 'tenant_profiles'::text, COUNT(*) FROM tenant_profiles p WHERE p.tenant_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = p.tenant_id)
    UNION ALL
    SELECT 'tenant_settings'::text, COUNT(*) FROM tenant_settings s WHERE s.tenant_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = s.tenant_id)
    UNION ALL
    SELECT 'tenant_api_credentials'::text, COUNT(*) FROM tenant_api_credentials c WHERE c.tenant_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = c.tenant_id)
    UNION ALL
    SELECT 'tenant_webhooks'::text, COUNT(*) FROM tenant_webhooks w WHERE w.tenant_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = w.tenant_id);
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_activity_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    admin_user_id uuid NOT NULL,
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    description text,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.admin_activity_logs FORCE ROW LEVEL SECURITY;


--
-- Name: admin_login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_login_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_user_id uuid,
    email character varying(255),
    successful boolean NOT NULL,
    failure_reason character varying(255),
    ip_address inet,
    user_agent text,
    attempted_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.admin_login_attempts FORCE ROW LEVEL SECURITY;


--
-- Name: admin_mfa_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_mfa_methods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_user_id uuid NOT NULL,
    method_type character varying(30) NOT NULL,
    secret_reference text,
    is_primary boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.admin_mfa_methods FORCE ROW LEVEL SECURITY;


--
-- Name: admin_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource character varying(100) NOT NULL,
    action public.permission_action_enum NOT NULL,
    code character varying(200) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE admin_permissions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.admin_permissions IS 'Fine-grained administrative permissions.';


--
-- Name: admin_role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_role_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    code character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    role_type public.admin_role_type_enum NOT NULL,
    is_system_role boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.admin_roles FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE admin_roles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.admin_roles IS 'RBAC roles for platform and tenant administrators.';


--
-- Name: admin_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_user_id uuid NOT NULL,
    session_token_hash text NOT NULL,
    ip_address inet,
    user_agent text,
    device_id character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_activity_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);

ALTER TABLE ONLY public.admin_sessions FORCE ROW LEVEL SECURITY;


--
-- Name: admin_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by uuid,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_role_expiry CHECK (((expires_at IS NULL) OR (expires_at > assigned_at)))
);

ALTER TABLE ONLY public.admin_user_roles FORCE ROW LEVEL SECURITY;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    email character varying(255) NOT NULL,
    phone_number character varying(30),
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    password_hash text,
    status public.admin_status_enum DEFAULT 'INVITED'::public.admin_status_enum NOT NULL,
    is_platform_admin boolean DEFAULT false NOT NULL,
    last_login_at timestamp with time zone,
    password_changed_at timestamp with time zone,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    authorization_version integer DEFAULT 1 NOT NULL,
    CONSTRAINT chk_admin_authorization_version CHECK ((authorization_version > 0)),
    CONSTRAINT chk_admin_email_format CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT chk_admin_failed_attempts CHECK ((failed_login_attempts >= 0)),
    CONSTRAINT chk_admin_scope_integrity CHECK (((is_platform_admin AND (tenant_id IS NULL)) OR ((NOT is_platform_admin) AND (tenant_id IS NOT NULL))))
);

ALTER TABLE ONLY public.admin_users FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE admin_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.admin_users IS 'Administrative users belonging to either the Parc platform or a tenant.';


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
)
PARTITION BY RANGE (created_at);

ALTER TABLE ONLY public.audit_logs FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE audit_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.audit_logs IS 'Platform-wide audit trail. Financial records must not rely on this table as the accounting source of truth.';


--
-- Name: audit_logs_2025_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2025_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2025_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2025_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2025_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2025_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2025_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2025_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_03; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_04; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_04 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_05 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_06; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_06 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_07; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_07 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_08; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_08 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_2026_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_2026_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: audit_logs_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    actor_type character varying(50),
    action public.audit_action_enum NOT NULL,
    resource_type character varying(100),
    resource_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: configuration_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuration_audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    scope public.configuration_scope_enum NOT NULL,
    configuration_id uuid,
    configuration_key character varying(200) NOT NULL,
    previous_value jsonb,
    new_value jsonb,
    action public.audit_action_enum NOT NULL,
    changed_by uuid,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.configuration_audit_logs FORCE ROW LEVEL SECURITY;


--
-- Name: configuration_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuration_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    configuration_key character varying(200) NOT NULL,
    data_type character varying(30) NOT NULL,
    validation_schema jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_secret boolean DEFAULT false NOT NULL,
    approval_policy character varying(20) DEFAULT 'REQUIRED'::character varying NOT NULL,
    classification character varying(30) DEFAULT 'OPERATIONAL'::character varying NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT configuration_definitions_approval_policy_check CHECK (((approval_policy)::text = ANY ((ARRAY['NONE'::character varying, 'REQUIRED'::character varying])::text[]))),
    CONSTRAINT configuration_definitions_classification_check CHECK (((classification)::text = ANY ((ARRAY['OPERATIONAL'::character varying, 'FINANCIAL'::character varying, 'SECURITY'::character varying, 'ACCESS'::character varying, 'PROVIDER'::character varying, 'PRICING'::character varying, 'LIMIT'::character varying, 'RISK'::character varying])::text[]))),
    CONSTRAINT configuration_definitions_data_type_check CHECK (((data_type)::text = ANY ((ARRAY['BOOLEAN'::character varying, 'INTEGER'::character varying, 'DECIMAL'::character varying, 'STRING'::character varying, 'JSON'::character varying])::text[])))
);


--
-- Name: configuration_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuration_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    definition_id uuid NOT NULL,
    scope character varying(20) NOT NULL,
    tenant_id uuid,
    tier_id uuid,
    version integer NOT NULL,
    value jsonb NOT NULL,
    status character varying(20) DEFAULT 'DRAFT'::character varying NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_until timestamp with time zone,
    approval_id uuid,
    created_by uuid NOT NULL,
    published_by uuid,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_configuration_period CHECK (((effective_until IS NULL) OR (effective_until > effective_from))),
    CONSTRAINT chk_configuration_publication CHECK (((((status)::text = 'PUBLISHED'::text) AND (published_by IS NOT NULL) AND (published_at IS NOT NULL)) OR ((status)::text <> 'PUBLISHED'::text))),
    CONSTRAINT chk_configuration_scope CHECK (((((scope)::text = 'SYSTEM'::text) AND (tenant_id IS NULL) AND (tier_id IS NULL)) OR (((scope)::text = 'TIER'::text) AND (tenant_id IS NULL) AND (tier_id IS NOT NULL)) OR (((scope)::text = 'TENANT'::text) AND (tenant_id IS NOT NULL) AND (tier_id IS NULL)))),
    CONSTRAINT configuration_versions_scope_check CHECK (((scope)::text = ANY ((ARRAY['SYSTEM'::character varying, 'TIER'::character varying, 'TENANT'::character varying])::text[]))),
    CONSTRAINT configuration_versions_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying, 'SUPERSEDED'::character varying, 'RETIRED'::character varying])::text[]))),
    CONSTRAINT configuration_versions_version_check CHECK ((version > 0))
);

ALTER TABLE ONLY public.configuration_versions FORCE ROW LEVEL SECURITY;


--
-- Name: data_access_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_access_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    admin_user_id uuid,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    access_type character varying(30) NOT NULL,
    fields_accessed jsonb,
    purpose text,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.data_access_logs FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE data_access_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.data_access_logs IS 'Audit trail for access to sensitive data.';


--
-- Name: feature_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_modules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_module_display_order CHECK ((display_order >= 0))
);


--
-- Name: feature_usage_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_usage_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    feature_id uuid NOT NULL,
    limit_name character varying(100) NOT NULL,
    limit_value numeric(20,2) NOT NULL,
    period character varying(30) DEFAULT 'DAILY'::character varying NOT NULL,
    reset_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_feature_limit CHECK ((limit_value >= (0)::numeric))
);

ALTER TABLE ONLY public.feature_usage_limits FORCE ROW LEVEL SECURITY;


--
-- Name: features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.features (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    module_id uuid NOT NULL,
    code character varying(150) NOT NULL,
    name character varying(200) NOT NULL,
    description text,
    status public.feature_status_enum DEFAULT 'ACTIVE'::public.feature_status_enum NOT NULL,
    value_type public.feature_value_type_enum DEFAULT 'BOOLEAN'::public.feature_value_type_enum NOT NULL,
    default_value jsonb,
    requires_configuration boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE features; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.features IS 'Master catalogue of all Parc platform features.';


--
-- Name: idempotency_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (expires_at);

ALTER TABLE ONLY public.idempotency_keys FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE idempotency_keys; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.idempotency_keys IS 'Prevents duplicate processing of administrative commands and operations.';


--
-- Name: idempotency_keys_2025_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2025_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2025_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2025_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2025_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2025_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2025_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2025_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_03; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_04; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_04 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_05 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_06; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_06 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_07; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_07 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_08; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_08 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_2026_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_2026_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: idempotency_keys_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    idempotency_key character varying(255) NOT NULL,
    request_hash character varying(128) NOT NULL,
    status public.idempotency_status_enum DEFAULT 'PROCESSING'::public.idempotency_status_enum NOT NULL,
    response_status integer,
    response_body jsonb,
    resource_type character varying(100),
    resource_id uuid,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: inbox_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inbox_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    event_id uuid NOT NULL,
    source_service character varying(100) NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    aggregate_type character varying(100),
    aggregate_id uuid,
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    headers jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.inbox_status_enum DEFAULT 'RECEIVED'::public.inbox_status_enum NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    processing_started_at timestamp with time zone,
    processed_at timestamp with time zone,
    next_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    CONSTRAINT chk_inbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_inbox_event_version CHECK ((event_version > 0))
);

ALTER TABLE ONLY public.inbox_events FORCE ROW LEVEL SECURITY;


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation_request_id uuid NOT NULL,
    action_type character varying(100) NOT NULL,
    performed_by uuid,
    status public.operation_status_enum NOT NULL,
    action_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    result_data jsonb,
    error_code character varying(100),
    error_message text,
    performed_at timestamp with time zone DEFAULT now() NOT NULL,
    performed_by_service character varying(100),
    CONSTRAINT chk_operation_action_actor CHECK (((((performed_by IS NOT NULL))::integer + ((performed_by_service IS NOT NULL))::integer) = 1))
);

ALTER TABLE ONLY public.operation_actions FORCE ROW LEVEL SECURITY;


--
-- Name: operation_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_approvals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation_request_id uuid NOT NULL,
    approver_id uuid NOT NULL,
    approval_level integer DEFAULT 1 NOT NULL,
    status public.operation_approval_status_enum DEFAULT 'PENDING'::public.operation_approval_status_enum NOT NULL,
    comments text,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_approval_level CHECK ((approval_level > 0))
);

ALTER TABLE ONLY public.operation_approvals FORCE ROW LEVEL SECURITY;


--
-- Name: operation_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation_request_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    content_type character varying(100),
    storage_provider character varying(50),
    storage_reference text NOT NULL,
    uploaded_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.operation_attachments FORCE ROW LEVEL SECURITY;


--
-- Name: operation_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation_request_id uuid NOT NULL,
    author_id uuid NOT NULL,
    comment text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.operation_comments FORCE ROW LEVEL SECURITY;


--
-- Name: operation_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    operation_reference character varying(100) NOT NULL,
    operation_type character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid NOT NULL,
    requested_by uuid NOT NULL,
    status public.operation_status_enum DEFAULT 'PENDING'::public.operation_status_enum NOT NULL,
    reason text NOT NULL,
    request_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    result_data jsonb,
    requires_approval boolean DEFAULT true NOT NULL,
    executed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    scope character varying(20) DEFAULT 'TENANT'::character varying NOT NULL,
    payload_hash character(64) NOT NULL,
    amount_minor bigint,
    currency character(3),
    expires_at timestamp with time zone NOT NULL,
    required_approval_count integer DEFAULT 1 NOT NULL,
    decided_at timestamp with time zone,
    consumed_at timestamp with time zone,
    consumed_by_service character varying(100),
    consumption_idempotency_key character varying(255),
    CONSTRAINT chk_operation_consumption CHECK ((((consumed_at IS NULL) AND (consumed_by_service IS NULL) AND (consumption_idempotency_key IS NULL)) OR ((consumed_at IS NOT NULL) AND (consumed_by_service IS NOT NULL) AND (consumption_idempotency_key IS NOT NULL)))),
    CONSTRAINT chk_operation_money_pair CHECK ((((amount_minor IS NULL) AND (currency IS NULL)) OR ((amount_minor IS NOT NULL) AND (amount_minor >= 0) AND (currency ~ '^[A-Z]{3}$'::text)))),
    CONSTRAINT chk_operation_payload_hash CHECK ((payload_hash ~ '^[a-f0-9]{64}$'::text)),
    CONSTRAINT chk_operation_required_approvals CHECK (((required_approval_count >= 1) AND (required_approval_count <= 3))),
    CONSTRAINT chk_operation_scope_tenant CHECK (((((scope)::text = 'TENANT'::text) AND (tenant_id IS NOT NULL)) OR (((scope)::text = 'PLATFORM'::text) AND (tenant_id IS NULL))))
);

ALTER TABLE ONLY public.operation_requests FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE operation_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.operation_requests IS 'Maker-checker operational requests executed by authorized administrators.';


--
-- Name: outbox_event_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_event_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    outbox_event_id uuid NOT NULL,
    outbox_event_created_at timestamp with time zone NOT NULL,
    attempt_number integer NOT NULL,
    status public.outbox_status_enum NOT NULL,
    broker character varying(50),
    topic character varying(255),
    partition_key character varying(255),
    error_code character varying(100),
    error_message text,
    attempted_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT chk_attempt_number CHECK ((attempt_number > 0))
);

ALTER TABLE ONLY public.outbox_event_attempts FORCE ROW LEVEL SECURITY;


--
-- Name: outbox_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
)
PARTITION BY RANGE (created_at);

ALTER TABLE ONLY public.outbox_events FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE outbox_events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.outbox_events IS 'Transactional outbox for reliable publication to Kafka, RabbitMQ or SQS.';


--
-- Name: outbox_events_2025_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2025_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2025_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2025_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2025_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2025_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2025_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2025_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_03; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_04; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_04 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_05 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_06; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_06 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_07; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_07 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_08; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_08 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_09 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_10 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_11 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_2026_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_2026_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: outbox_events_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_events_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    aggregate_type character varying(100) NOT NULL,
    aggregate_id uuid NOT NULL,
    event_type character varying(150) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    idempotency_key character varying(255),
    correlation_id uuid,
    causation_id uuid,
    payload jsonb NOT NULL,
    status public.outbox_status_enum DEFAULT 'PENDING'::public.outbox_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error_code character varying(100),
    last_error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_outbox_attempt_count CHECK ((attempt_count >= 0)),
    CONSTRAINT chk_outbox_event_version CHECK ((event_version > 0))
);


--
-- Name: provider_capabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_capabilities (
    provider_code character varying(50) NOT NULL,
    capability character varying(40) NOT NULL,
    currency character(3),
    is_enabled boolean DEFAULT false NOT NULL,
    availability character varying(20) DEFAULT 'UNAVAILABLE'::character varying NOT NULL,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    CONSTRAINT chk_provider_capability_currency CHECK (((((capability)::text = ANY ((ARRAY['VIRTUAL_ACCOUNT'::character varying, 'COLLECTION'::character varying, 'INTERBANK_TRANSFER'::character varying, 'DIRECT_DEBIT'::character varying, 'BILL_PAYMENT'::character varying])::text[])) AND (currency ~ '^[A-Z]{3}$'::text)) OR (((capability)::text = ANY ((ARRAY['KYC'::character varying, 'EMAIL'::character varying, 'SMS'::character varying, 'PUSH_NOTIFICATION'::character varying])::text[])) AND (currency IS NULL)))),
    CONSTRAINT provider_capabilities_availability_check CHECK (((availability)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'DEGRADED'::character varying, 'UNAVAILABLE'::character varying])::text[]))),
    CONSTRAINT provider_capabilities_capability_check CHECK (((capability)::text = ANY ((ARRAY['VIRTUAL_ACCOUNT'::character varying, 'COLLECTION'::character varying, 'INTERBANK_TRANSFER'::character varying, 'DIRECT_DEBIT'::character varying, 'BILL_PAYMENT'::character varying, 'KYC'::character varying, 'EMAIL'::character varying, 'SMS'::character varying, 'PUSH_NOTIFICATION'::character varying])::text[])))
);


--
-- Name: provider_capability_availability_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_capability_availability_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_capability_id uuid NOT NULL,
    provider_code character varying(50) NOT NULL,
    capability character varying(40) NOT NULL,
    currency character(3),
    previous_is_enabled boolean,
    previous_availability character varying(20),
    is_enabled boolean NOT NULL,
    availability character varying(20) NOT NULL,
    approval_id uuid NOT NULL,
    changed_by uuid NOT NULL,
    reason text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT provider_capability_availability_history_availability_check CHECK (((availability)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'DEGRADED'::character varying, 'UNAVAILABLE'::character varying])::text[])))
);

ALTER TABLE ONLY public.provider_capability_availability_history FORCE ROW LEVEL SECURITY;


--
-- Name: provider_catalog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_catalog (
    provider_code character varying(50) NOT NULL,
    display_name character varying(100) NOT NULL,
    category character varying(30) NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    availability character varying(20) DEFAULT 'UNAVAILABLE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT provider_catalog_availability_check CHECK (((availability)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'DEGRADED'::character varying, 'UNAVAILABLE'::character varying])::text[]))),
    CONSTRAINT provider_catalog_category_check CHECK (((category)::text = ANY ((ARRAY['FINANCIAL'::character varying, 'KYC'::character varying, 'EMAIL'::character varying, 'SMS'::character varying, 'PUSH'::character varying])::text[])))
);


--
-- Name: TABLE provider_catalog; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.provider_catalog IS 'Platform-owned provider discovery catalog. Contains no provider credentials.';


--
-- Name: reconciliation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_exception_id uuid NOT NULL,
    action_type character varying(100) NOT NULL,
    performed_by uuid NOT NULL,
    action_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    result_data jsonb,
    performed_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.reconciliation_actions FORCE ROW LEVEL SECURITY;


--
-- Name: reconciliation_exceptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation_exceptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_item_id uuid NOT NULL,
    tenant_id uuid,
    exception_code character varying(100) NOT NULL,
    description text NOT NULL,
    status public.reconciliation_exception_status_enum DEFAULT 'OPEN'::public.reconciliation_exception_status_enum NOT NULL,
    severity character varying(30) DEFAULT 'MEDIUM'::character varying NOT NULL,
    assigned_to uuid,
    resolution_notes text,
    resolved_by uuid,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.reconciliation_exceptions FORCE ROW LEVEL SECURITY;


--
-- Name: reconciliation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    tenant_id uuid,
    source_reference character varying(255),
    target_reference character varying(255),
    source_amount numeric(20,2),
    target_amount numeric(20,2),
    currency character(3),
    status public.reconciliation_item_status_enum NOT NULL,
    difference_amount numeric(20,2),
    source_data jsonb,
    target_data jsonb,
    matched_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.reconciliation_items FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE reconciliation_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reconciliation_items IS 'Individual reconciliation comparisons between source and target systems.';


--
-- Name: reconciliation_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    job_code character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    source_system character varying(100) NOT NULL,
    target_system character varying(100) NOT NULL,
    reconciliation_type character varying(100) NOT NULL,
    schedule_expression character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.reconciliation_jobs FORCE ROW LEVEL SECURITY;


--
-- Name: reconciliation_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_job_id uuid NOT NULL,
    run_reference character varying(100) NOT NULL,
    status public.reconciliation_status_enum DEFAULT 'PENDING'::public.reconciliation_status_enum NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    total_records bigint DEFAULT 0 NOT NULL,
    matched_records bigint DEFAULT 0 NOT NULL,
    unmatched_records bigint DEFAULT 0 NOT NULL,
    exception_records bigint DEFAULT 0 NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_reconciliation_counts CHECK (((total_records >= 0) AND (matched_records >= 0) AND (unmatched_records >= 0) AND (exception_records >= 0)))
);

ALTER TABLE ONLY public.reconciliation_runs FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE reconciliation_runs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reconciliation_runs IS 'Execution instances of reconciliation jobs.';


--
-- Name: security_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    admin_user_id uuid,
    event_type public.security_event_type_enum NOT NULL,
    severity character varying(30) DEFAULT 'MEDIUM'::character varying NOT NULL,
    ip_address inet,
    user_agent text,
    description text,
    resolved boolean DEFAULT false NOT NULL,
    resolved_by uuid,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.security_events FORCE ROW LEVEL SECURITY;


--
-- Name: support_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    code character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.support_categories FORCE ROW LEVEL SECURITY;


--
-- Name: support_ticket_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_ticket_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid NOT NULL,
    admin_user_id uuid NOT NULL,
    assigned_by uuid,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    unassigned_at timestamp with time zone
);

ALTER TABLE ONLY public.support_ticket_assignments FORCE ROW LEVEL SECURITY;


--
-- Name: support_ticket_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_ticket_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid NOT NULL,
    event_type character varying(100) NOT NULL,
    previous_status public.support_ticket_status_enum,
    new_status public.support_ticket_status_enum,
    performed_by uuid,
    event_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.support_ticket_events FORCE ROW LEVEL SECURITY;


--
-- Name: support_ticket_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_ticket_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid NOT NULL,
    sender_type character varying(30) NOT NULL,
    sender_id uuid,
    message text NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.support_ticket_messages FORCE ROW LEVEL SECURITY;


--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ticket_reference character varying(100) NOT NULL,
    customer_id uuid,
    category_id uuid,
    subject character varying(255) NOT NULL,
    description text NOT NULL,
    status public.support_ticket_status_enum DEFAULT 'OPEN'::public.support_ticket_status_enum NOT NULL,
    priority public.support_ticket_priority_enum DEFAULT 'MEDIUM'::public.support_ticket_priority_enum NOT NULL,
    channel public.support_ticket_channel_enum DEFAULT 'IN_APP'::public.support_ticket_channel_enum NOT NULL,
    assigned_admin_id uuid,
    opened_at timestamp with time zone DEFAULT now() NOT NULL,
    first_response_at timestamp with time zone,
    resolved_at timestamp with time zone,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.support_tickets FORCE ROW LEVEL SECURITY;


--
-- Name: system_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    configuration_key character varying(200) NOT NULL,
    configuration_value jsonb NOT NULL,
    data_type character varying(30) DEFAULT 'JSON'::character varying NOT NULL,
    is_secret boolean DEFAULT false NOT NULL,
    description text,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_system_configuration_version CHECK ((version > 0))
);


--
-- Name: TABLE system_configurations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_configurations IS 'Global Parc platform configuration.';


--
-- Name: tenant_api_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_api_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    client_id character varying(150) NOT NULL,
    secret_reference character varying(500),
    environment character varying(20) DEFAULT 'PRODUCTION'::character varying NOT NULL,
    scopes jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.tenant_api_credentials FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_commercial_agreements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_commercial_agreements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    agreement_reference character varying(100) NOT NULL,
    agreement_name character varying(200) NOT NULL,
    agreement_version integer DEFAULT 1 NOT NULL,
    status public.commercial_agreement_status DEFAULT 'DRAFT'::public.commercial_agreement_status NOT NULL,
    effective_from timestamp with time zone,
    effective_to timestamp with time zone,
    signed_at timestamp with time zone,
    tenant_signatory_name character varying(200),
    tenant_signatory_title character varying(150),
    parc_signatory_name character varying(200),
    parc_signatory_title character varying(150),
    document_reference character varying(500),
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_by uuid,
    updated_by uuid,
    approved_by uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_tenant_commercial_agreement_approval CHECK ((((approved_at IS NULL) AND (approved_by IS NULL)) OR ((approved_at IS NOT NULL) AND (approved_by IS NOT NULL)))),
    CONSTRAINT chk_tenant_commercial_agreement_period CHECK (((effective_to IS NULL) OR (effective_from IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT tenant_commercial_agreements_agreement_version_check CHECK ((agreement_version > 0))
);

ALTER TABLE ONLY public.tenant_commercial_agreements FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_commercial_agreements; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_commercial_agreements IS 'Versioned commercial agreement header between Parc and a tenant.';


--
-- Name: tenant_configuration_publications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_configuration_publications (
    tenant_id uuid NOT NULL,
    configuration_version bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tenant_configuration_publications_configuration_version_check CHECK ((configuration_version >= 0))
);

ALTER TABLE ONLY public.tenant_configuration_publications FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    configuration_key character varying(200) NOT NULL,
    configuration_value jsonb NOT NULL,
    data_type character varying(30) DEFAULT 'JSON'::character varying NOT NULL,
    is_secret boolean DEFAULT false NOT NULL,
    description text,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_configuration_version CHECK ((version > 0))
);

ALTER TABLE ONLY public.tenant_configurations FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_configurations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_configurations IS 'Tenant-specific operational and business configuration.';


--
-- Name: tenant_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_domains (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    domain character varying(255) NOT NULL,
    domain_type character varying(30) DEFAULT 'CUSTOM'::character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_token character varying(255),
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.tenant_domains FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_feature_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_feature_overrides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    feature_id uuid NOT NULL,
    override_type public.feature_override_type_enum NOT NULL,
    enabled boolean,
    value jsonb,
    usage_limit numeric(20,2),
    reason text,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_override_dates CHECK (((effective_until IS NULL) OR (effective_until > effective_from)))
);

ALTER TABLE ONLY public.tenant_feature_overrides FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_feature_overrides; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_feature_overrides IS 'Tenant-specific feature entitlement overrides without modifying the base tier.';


--
-- Name: tenant_feature_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_feature_usage (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    feature_id uuid NOT NULL,
    usage_date date DEFAULT CURRENT_DATE NOT NULL,
    usage_count bigint DEFAULT 0 NOT NULL,
    usage_amount numeric(20,2) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_usage_amount CHECK ((usage_amount >= (0)::numeric)),
    CONSTRAINT chk_usage_count CHECK ((usage_count >= 0))
);

ALTER TABLE ONLY public.tenant_feature_usage FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    logo_url text,
    website_url text,
    primary_email character varying(255),
    support_email character varying(255),
    phone_number character varying(30),
    address_line_1 character varying(255),
    address_line_2 character varying(255),
    city character varying(100),
    state character varying(100),
    postal_code character varying(30),
    contact_person_name character varying(255),
    contact_person_email character varying(255),
    contact_person_phone character varying(30),
    branding jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_tenant_profiles_primary_email_format CHECK (((primary_email IS NULL) OR ((primary_email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text))),
    CONSTRAINT chk_tenant_profiles_website_url_length CHECK (((website_url IS NULL) OR (length(website_url) <= 2000)))
);

ALTER TABLE ONLY public.tenant_profiles FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_provider_selection_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_provider_selection_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    selection_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    capability character varying(40) NOT NULL,
    currency character(3),
    previous_provider_code character varying(50),
    provider_code character varying(50) NOT NULL,
    version integer NOT NULL,
    approval_id uuid NOT NULL,
    selected_by uuid NOT NULL,
    reason text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tenant_provider_selection_history_version_check CHECK ((version > 0))
);

ALTER TABLE ONLY public.tenant_provider_selection_history FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_provider_selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_provider_selections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    capability character varying(40) NOT NULL,
    currency character(3),
    provider_code character varying(50) NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    approval_id uuid NOT NULL,
    selected_by uuid NOT NULL,
    reason text NOT NULL,
    selected_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_tenant_selection_currency CHECK (((((capability)::text = ANY ((ARRAY['VIRTUAL_ACCOUNT'::character varying, 'COLLECTION'::character varying, 'INTERBANK_TRANSFER'::character varying, 'DIRECT_DEBIT'::character varying, 'BILL_PAYMENT'::character varying])::text[])) AND (currency ~ '^[A-Z]{3}$'::text)) OR (((capability)::text = ANY ((ARRAY['KYC'::character varying, 'EMAIL'::character varying, 'SMS'::character varying, 'PUSH_NOTIFICATION'::character varying])::text[])) AND (currency IS NULL)))),
    CONSTRAINT tenant_provider_selections_version_check CHECK ((version > 0))
);

ALTER TABLE ONLY public.tenant_provider_selections FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_revenue_settlement_configuration_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_revenue_settlement_configuration_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    settlement_configuration_id uuid NOT NULL,
    version_number integer NOT NULL,
    action character varying(50) NOT NULL,
    snapshot jsonb NOT NULL,
    changed_by uuid,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    CONSTRAINT tenant_revenue_settlement_configuration_hi_version_number_check CHECK ((version_number > 0)),
    CONSTRAINT tenant_revenue_settlement_configuration_history_action_check CHECK (((action)::text = ANY ((ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'ACTIVATED'::character varying, 'DEACTIVATED'::character varying, 'EXPIRED'::character varying])::text[])))
);

ALTER TABLE ONLY public.tenant_revenue_settlement_configuration_history FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_revenue_settlement_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_revenue_settlement_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    agreement_id uuid,
    configuration_name character varying(200) NOT NULL,
    settlement_frequency public.settlement_frequency DEFAULT 'MONTHLY'::public.settlement_frequency NOT NULL,
    funding_mode public.settlement_funding_mode DEFAULT 'BANK_TRANSFER'::public.settlement_funding_mode NOT NULL,
    currency_code character(3) DEFAULT 'NGN'::bpchar NOT NULL,
    minimum_settlement_amount numeric(20,2) DEFAULT 0 NOT NULL,
    maximum_settlement_amount numeric(20,2),
    settlement_day_of_week smallint,
    settlement_day_of_month smallint,
    settlement_hour smallint DEFAULT 10 NOT NULL,
    settlement_timezone character varying(100) DEFAULT 'Africa/Lagos'::character varying NOT NULL,
    auto_settle boolean DEFAULT false NOT NULL,
    fee_bearer public.fee_bearer_type DEFAULT 'TENANT'::public.fee_bearer_type NOT NULL,
    destination_account_reference character varying(255),
    destination_bank_code character varying(50),
    destination_account_name character varying(200),
    provider_code character varying(100),
    secret_reference character varying(500),
    retry_enabled boolean DEFAULT true NOT NULL,
    max_retry_attempts integer DEFAULT 5 NOT NULL,
    retry_delay_minutes integer DEFAULT 60 NOT NULL,
    require_reconciliation_before_settlement boolean DEFAULT true NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_by uuid,
    updated_by uuid,
    approved_by uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_monthly_config CHECK (((settlement_frequency <> 'MONTHLY'::public.settlement_frequency) OR (settlement_day_of_month IS NOT NULL))),
    CONSTRAINT chk_settlement_amounts CHECK (((minimum_settlement_amount >= (0)::numeric) AND ((maximum_settlement_amount IS NULL) OR (maximum_settlement_amount >= minimum_settlement_amount)))),
    CONSTRAINT chk_settlement_approval CHECK ((((approved_at IS NULL) AND (approved_by IS NULL)) OR ((approved_at IS NOT NULL) AND (approved_by IS NOT NULL)))),
    CONSTRAINT chk_settlement_hour CHECK (((settlement_hour >= 0) AND (settlement_hour <= 23))),
    CONSTRAINT chk_settlement_monthday CHECK (((settlement_day_of_month IS NULL) OR ((settlement_day_of_month >= 1) AND (settlement_day_of_month <= 28)))),
    CONSTRAINT chk_settlement_period CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT chk_settlement_retry CHECK (((max_retry_attempts >= 0) AND (retry_delay_minutes >= 0))),
    CONSTRAINT chk_settlement_weekday CHECK (((settlement_day_of_week IS NULL) OR ((settlement_day_of_week >= 1) AND (settlement_day_of_week <= 7)))),
    CONSTRAINT chk_weekly_config CHECK (((settlement_frequency <> 'WEEKLY'::public.settlement_frequency) OR (settlement_day_of_week IS NOT NULL))),
    CONSTRAINT tenant_revenue_settlement_configurations_currency_code_check CHECK ((currency_code ~ '^[A-Z]{3}$'::text))
);

ALTER TABLE ONLY public.tenant_revenue_settlement_configurations FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_revenue_settlement_configurations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_revenue_settlement_configurations IS 'Defines how and when earned Parc revenue should be funded. Actual settlement transactions belong in parc_payment.';


--
-- Name: COLUMN tenant_revenue_settlement_configurations.secret_reference; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant_revenue_settlement_configurations.secret_reference IS 'Vault/AWS Secrets Manager reference. Never store provider credentials directly here.';


--
-- Name: tenant_revenue_share_rule_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_revenue_share_rule_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    revenue_share_rule_id uuid NOT NULL,
    version_number integer NOT NULL,
    action character varying(50) NOT NULL,
    snapshot jsonb NOT NULL,
    changed_by uuid,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    CONSTRAINT tenant_revenue_share_rule_history_action_check CHECK (((action)::text = ANY ((ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'ACTIVATED'::character varying, 'SUSPENDED'::character varying, 'EXPIRED'::character varying, 'TERMINATED'::character varying])::text[]))),
    CONSTRAINT tenant_revenue_share_rule_history_version_number_check CHECK ((version_number > 0))
);

ALTER TABLE ONLY public.tenant_revenue_share_rule_history FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_revenue_share_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_revenue_share_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    agreement_id uuid,
    rule_code character varying(100) NOT NULL,
    rule_name character varying(200) NOT NULL,
    revenue_type public.platform_revenue_type NOT NULL,
    calculation_basis public.revenue_calculation_basis NOT NULL,
    calculation_method public.revenue_calculation_method DEFAULT 'PERCENTAGE'::public.revenue_calculation_method NOT NULL,
    percentage_rate numeric(12,6),
    fixed_amount numeric(20,2),
    currency_code character(3) DEFAULT 'NGN'::bpchar NOT NULL,
    minimum_revenue_amount numeric(20,2),
    maximum_revenue_amount numeric(20,2),
    minimum_source_amount numeric(20,2),
    maximum_source_amount numeric(20,2),
    status public.revenue_rule_status DEFAULT 'DRAFT'::public.revenue_rule_status NOT NULL,
    priority integer DEFAULT 100 NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    product_code character varying(100),
    channel_code character varying(100),
    provider_code character varying(100),
    applies_to_all_products boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_by uuid,
    updated_by uuid,
    approved_by uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_share_approval CHECK ((((approved_at IS NULL) AND (approved_by IS NULL)) OR ((approved_at IS NOT NULL) AND (approved_by IS NOT NULL)))),
    CONSTRAINT chk_share_fixed CHECK (((fixed_amount IS NULL) OR (fixed_amount >= (0)::numeric))),
    CONSTRAINT chk_share_method CHECK ((((calculation_method = 'PERCENTAGE'::public.revenue_calculation_method) AND (percentage_rate IS NOT NULL)) OR ((calculation_method = 'FIXED_AMOUNT'::public.revenue_calculation_method) AND (fixed_amount IS NOT NULL)) OR ((calculation_method = 'PERCENTAGE_PLUS_FIXED'::public.revenue_calculation_method) AND (percentage_rate IS NOT NULL) AND (fixed_amount IS NOT NULL)) OR (calculation_method = 'TIERED'::public.revenue_calculation_method))),
    CONSTRAINT chk_share_percentage CHECK (((percentage_rate IS NULL) OR ((percentage_rate >= (0)::numeric) AND (percentage_rate <= (100)::numeric)))),
    CONSTRAINT chk_share_period CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT chk_share_revenue_bounds CHECK (((minimum_revenue_amount IS NULL) OR (maximum_revenue_amount IS NULL) OR (maximum_revenue_amount >= minimum_revenue_amount))),
    CONSTRAINT chk_share_source_bounds CHECK (((minimum_source_amount IS NULL) OR (maximum_source_amount IS NULL) OR (maximum_source_amount >= minimum_source_amount))),
    CONSTRAINT tenant_revenue_share_rules_currency_code_check CHECK ((currency_code ~ '^[A-Z]{3}$'::text)),
    CONSTRAINT tenant_revenue_share_rules_priority_check CHECK ((priority >= 0))
);

ALTER TABLE ONLY public.tenant_revenue_share_rules FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_revenue_share_rules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_revenue_share_rules IS 'Effective-dated rules used to calculate Parc revenue. Transactional services must snapshot the applied rule/rate.';


--
-- Name: tenant_revenue_share_tiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_revenue_share_tiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    revenue_share_rule_id uuid NOT NULL,
    tier_order integer NOT NULL,
    lower_bound_amount numeric(20,2) DEFAULT 0 NOT NULL,
    upper_bound_amount numeric(20,2),
    percentage_rate numeric(12,6),
    fixed_amount numeric(20,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_tier_bounds CHECK (((lower_bound_amount >= (0)::numeric) AND ((upper_bound_amount IS NULL) OR (upper_bound_amount > lower_bound_amount)))),
    CONSTRAINT chk_tier_fixed CHECK (((fixed_amount IS NULL) OR (fixed_amount >= (0)::numeric))),
    CONSTRAINT chk_tier_percentage CHECK (((percentage_rate IS NULL) OR ((percentage_rate >= (0)::numeric) AND (percentage_rate <= (100)::numeric)))),
    CONSTRAINT chk_tier_value CHECK (((percentage_rate IS NOT NULL) OR (fixed_amount IS NOT NULL))),
    CONSTRAINT tenant_revenue_share_tiers_tier_order_check CHECK ((tier_order > 0))
);

ALTER TABLE ONLY public.tenant_revenue_share_tiers FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_revenue_share_tiers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_revenue_share_tiers IS 'Tier bands used only by TIERED revenue-share rules.';


--
-- Name: tenant_service_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_service_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    service_code character varying(100) NOT NULL,
    provider_code character varying(100) NOT NULL,
    environment character varying(30) DEFAULT 'PRODUCTION'::character varying NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    secret_reference text,
    is_active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_service_configuration_dates CHECK (((effective_until IS NULL) OR (effective_until > effective_from))),
    CONSTRAINT chk_service_priority CHECK ((priority > 0))
);

ALTER TABLE ONLY public.tenant_service_configurations FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenant_service_configurations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_service_configurations IS 'Tenant-specific external service/provider configuration. Secrets must remain in Vault or a secrets manager.';


--
-- Name: tenant_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    timezone character varying(100) DEFAULT 'Africa/Lagos'::character varying NOT NULL,
    locale character varying(20) DEFAULT 'en-NG'::character varying NOT NULL,
    date_format character varying(50) DEFAULT 'DD/MM/YYYY'::character varying,
    default_currency character(3) DEFAULT 'NGN'::bpchar NOT NULL,
    notification_settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    security_settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    transaction_settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone
);

ALTER TABLE ONLY public.tenant_settings FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_status_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    previous_status public.tenant_status_enum,
    new_status public.tenant_status_enum NOT NULL,
    reason text,
    changed_by uuid,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.tenant_status_history FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_tiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_tiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code public.tenant_tier_code_enum NOT NULL,
    platinum_level public.platinum_level_enum,
    name character varying(100) NOT NULL,
    description text,
    price numeric(20,2),
    currency character(3) DEFAULT 'NGN'::bpchar,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_platinum_level CHECK ((((code = 'PLATINUM'::public.tenant_tier_code_enum) AND (platinum_level IS NOT NULL)) OR ((code <> 'PLATINUM'::public.tenant_tier_code_enum) AND (platinum_level IS NULL)))),
    CONSTRAINT chk_tier_price CHECK (((price IS NULL) OR (price >= (0)::numeric)))
);


--
-- Name: TABLE tenant_tiers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant_tiers IS 'Subscription/service tiers: BASIC, PREMIUM and PLATINUM levels 1-3.';


--
-- Name: tenant_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_webhooks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    endpoint_url text NOT NULL,
    secret_reference character varying(500),
    subscribed_events jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL,
    last_success_at timestamp with time zone,
    last_failure_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_webhook_failure_count CHECK ((failure_count >= 0))
);

ALTER TABLE ONLY public.tenant_webhooks FORCE ROW LEVEL SECURITY;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_code character varying(50) NOT NULL,
    legal_name character varying(255) NOT NULL,
    trading_name character varying(255),
    tenant_type public.tenant_type_enum NOT NULL,
    registration_number character varying(100),
    license_number character varying(100),
    country_code character(2) DEFAULT 'NG'::bpchar NOT NULL,
    currency_code character(3) DEFAULT 'NGN'::bpchar NOT NULL,
    status public.tenant_status_enum DEFAULT 'PENDING'::public.tenant_status_enum NOT NULL,
    tier_id uuid,
    onboarding_completed_at timestamp with time zone,
    activated_at timestamp with time zone,
    suspended_at timestamp with time zone,
    deactivated_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_tenant_country CHECK ((country_code ~ '^[A-Z]{2}$'::text)),
    CONSTRAINT chk_tenant_currency CHECK ((currency_code ~ '^[A-Z]{3}$'::text))
);

ALTER TABLE ONLY public.tenants FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tenants; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenants IS 'Master tenant registry for MFBs, banks, fintechs and other institutions using Parc.';


--
-- Name: tier_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tier_features (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tier_id uuid NOT NULL,
    feature_id uuid NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    value jsonb,
    usage_limit numeric(20,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.tier_features FORCE ROW LEVEL SECURITY;


--
-- Name: TABLE tier_features; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tier_features IS 'Defines which features and limits are included in each tenant tier.';


--
-- Name: audit_logs_2025_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2025_09 FOR VALUES FROM ('2025-09-01 00:00:00+01') TO ('2025-10-01 00:00:00+01');


--
-- Name: audit_logs_2025_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2025_10 FOR VALUES FROM ('2025-10-01 00:00:00+01') TO ('2025-11-01 00:00:00+01');


--
-- Name: audit_logs_2025_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2025_11 FOR VALUES FROM ('2025-11-01 00:00:00+01') TO ('2025-12-01 00:00:00+01');


--
-- Name: audit_logs_2025_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2025_12 FOR VALUES FROM ('2025-12-01 00:00:00+01') TO ('2026-01-01 00:00:00+01');


--
-- Name: audit_logs_2026_01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_01 FOR VALUES FROM ('2026-01-01 00:00:00+01') TO ('2026-02-01 00:00:00+01');


--
-- Name: audit_logs_2026_02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_02 FOR VALUES FROM ('2026-02-01 00:00:00+01') TO ('2026-03-01 00:00:00+01');


--
-- Name: audit_logs_2026_03; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_03 FOR VALUES FROM ('2026-03-01 00:00:00+01') TO ('2026-04-01 00:00:00+01');


--
-- Name: audit_logs_2026_04; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_04 FOR VALUES FROM ('2026-04-01 00:00:00+01') TO ('2026-05-01 00:00:00+01');


--
-- Name: audit_logs_2026_05; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_05 FOR VALUES FROM ('2026-05-01 00:00:00+01') TO ('2026-06-01 00:00:00+01');


--
-- Name: audit_logs_2026_06; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_06 FOR VALUES FROM ('2026-06-01 00:00:00+01') TO ('2026-07-01 00:00:00+01');


--
-- Name: audit_logs_2026_07; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_07 FOR VALUES FROM ('2026-07-01 00:00:00+01') TO ('2026-08-01 00:00:00+01');


--
-- Name: audit_logs_2026_08; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_08 FOR VALUES FROM ('2026-08-01 00:00:00+01') TO ('2026-09-01 00:00:00+01');


--
-- Name: audit_logs_2026_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_09 FOR VALUES FROM ('2026-09-01 00:00:00+01') TO ('2026-10-01 00:00:00+01');


--
-- Name: audit_logs_2026_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_10 FOR VALUES FROM ('2026-10-01 00:00:00+01') TO ('2026-11-01 00:00:00+01');


--
-- Name: audit_logs_2026_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_11 FOR VALUES FROM ('2026-11-01 00:00:00+01') TO ('2026-12-01 00:00:00+01');


--
-- Name: audit_logs_2026_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_2026_12 FOR VALUES FROM ('2026-12-01 00:00:00+01') TO ('2027-01-01 00:00:00+01');


--
-- Name: audit_logs_default; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ATTACH PARTITION public.audit_logs_default DEFAULT;


--
-- Name: idempotency_keys_2025_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2025_09 FOR VALUES FROM ('2025-09-01 00:00:00+01') TO ('2025-10-01 00:00:00+01');


--
-- Name: idempotency_keys_2025_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2025_10 FOR VALUES FROM ('2025-10-01 00:00:00+01') TO ('2025-11-01 00:00:00+01');


--
-- Name: idempotency_keys_2025_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2025_11 FOR VALUES FROM ('2025-11-01 00:00:00+01') TO ('2025-12-01 00:00:00+01');


--
-- Name: idempotency_keys_2025_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2025_12 FOR VALUES FROM ('2025-12-01 00:00:00+01') TO ('2026-01-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_01 FOR VALUES FROM ('2026-01-01 00:00:00+01') TO ('2026-02-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_02 FOR VALUES FROM ('2026-02-01 00:00:00+01') TO ('2026-03-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_03; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_03 FOR VALUES FROM ('2026-03-01 00:00:00+01') TO ('2026-04-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_04; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_04 FOR VALUES FROM ('2026-04-01 00:00:00+01') TO ('2026-05-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_05; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_05 FOR VALUES FROM ('2026-05-01 00:00:00+01') TO ('2026-06-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_06; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_06 FOR VALUES FROM ('2026-06-01 00:00:00+01') TO ('2026-07-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_07; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_07 FOR VALUES FROM ('2026-07-01 00:00:00+01') TO ('2026-08-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_08; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_08 FOR VALUES FROM ('2026-08-01 00:00:00+01') TO ('2026-09-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_09 FOR VALUES FROM ('2026-09-01 00:00:00+01') TO ('2026-10-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_10 FOR VALUES FROM ('2026-10-01 00:00:00+01') TO ('2026-11-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_11 FOR VALUES FROM ('2026-11-01 00:00:00+01') TO ('2026-12-01 00:00:00+01');


--
-- Name: idempotency_keys_2026_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_2026_12 FOR VALUES FROM ('2026-12-01 00:00:00+01') TO ('2027-01-01 00:00:00+01');


--
-- Name: idempotency_keys_default; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys ATTACH PARTITION public.idempotency_keys_default DEFAULT;


--
-- Name: outbox_events_2025_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2025_09 FOR VALUES FROM ('2025-09-01 00:00:00+01') TO ('2025-10-01 00:00:00+01');


--
-- Name: outbox_events_2025_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2025_10 FOR VALUES FROM ('2025-10-01 00:00:00+01') TO ('2025-11-01 00:00:00+01');


--
-- Name: outbox_events_2025_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2025_11 FOR VALUES FROM ('2025-11-01 00:00:00+01') TO ('2025-12-01 00:00:00+01');


--
-- Name: outbox_events_2025_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2025_12 FOR VALUES FROM ('2025-12-01 00:00:00+01') TO ('2026-01-01 00:00:00+01');


--
-- Name: outbox_events_2026_01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_01 FOR VALUES FROM ('2026-01-01 00:00:00+01') TO ('2026-02-01 00:00:00+01');


--
-- Name: outbox_events_2026_02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_02 FOR VALUES FROM ('2026-02-01 00:00:00+01') TO ('2026-03-01 00:00:00+01');


--
-- Name: outbox_events_2026_03; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_03 FOR VALUES FROM ('2026-03-01 00:00:00+01') TO ('2026-04-01 00:00:00+01');


--
-- Name: outbox_events_2026_04; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_04 FOR VALUES FROM ('2026-04-01 00:00:00+01') TO ('2026-05-01 00:00:00+01');


--
-- Name: outbox_events_2026_05; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_05 FOR VALUES FROM ('2026-05-01 00:00:00+01') TO ('2026-06-01 00:00:00+01');


--
-- Name: outbox_events_2026_06; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_06 FOR VALUES FROM ('2026-06-01 00:00:00+01') TO ('2026-07-01 00:00:00+01');


--
-- Name: outbox_events_2026_07; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_07 FOR VALUES FROM ('2026-07-01 00:00:00+01') TO ('2026-08-01 00:00:00+01');


--
-- Name: outbox_events_2026_08; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_08 FOR VALUES FROM ('2026-08-01 00:00:00+01') TO ('2026-09-01 00:00:00+01');


--
-- Name: outbox_events_2026_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_09 FOR VALUES FROM ('2026-09-01 00:00:00+01') TO ('2026-10-01 00:00:00+01');


--
-- Name: outbox_events_2026_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_10 FOR VALUES FROM ('2026-10-01 00:00:00+01') TO ('2026-11-01 00:00:00+01');


--
-- Name: outbox_events_2026_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_11 FOR VALUES FROM ('2026-11-01 00:00:00+01') TO ('2026-12-01 00:00:00+01');


--
-- Name: outbox_events_2026_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_2026_12 FOR VALUES FROM ('2026-12-01 00:00:00+01') TO ('2027-01-01 00:00:00+01');


--
-- Name: outbox_events_default; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events ATTACH PARTITION public.outbox_events_default DEFAULT;


--
-- Name: admin_activity_logs admin_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_activity_logs
    ADD CONSTRAINT admin_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_login_attempts admin_login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_login_attempts
    ADD CONSTRAINT admin_login_attempts_pkey PRIMARY KEY (id);


--
-- Name: admin_mfa_methods admin_mfa_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_mfa_methods
    ADD CONSTRAINT admin_mfa_methods_pkey PRIMARY KEY (id);


--
-- Name: admin_permissions admin_permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_code_key UNIQUE (code);


--
-- Name: admin_permissions admin_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_role_permissions admin_role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions
    ADD CONSTRAINT admin_role_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_roles admin_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_roles
    ADD CONSTRAINT admin_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_sessions admin_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_pkey PRIMARY KEY (id);


--
-- Name: admin_sessions admin_sessions_session_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_session_token_hash_key UNIQUE (session_token_hash);


--
-- Name: admin_user_roles admin_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT admin_user_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2025_09 audit_logs_2025_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2025_09
    ADD CONSTRAINT audit_logs_2025_09_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2025_10 audit_logs_2025_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2025_10
    ADD CONSTRAINT audit_logs_2025_10_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2025_11 audit_logs_2025_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2025_11
    ADD CONSTRAINT audit_logs_2025_11_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2025_12 audit_logs_2025_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2025_12
    ADD CONSTRAINT audit_logs_2025_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_01 audit_logs_2026_01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_01
    ADD CONSTRAINT audit_logs_2026_01_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_02 audit_logs_2026_02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_02
    ADD CONSTRAINT audit_logs_2026_02_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_03 audit_logs_2026_03_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_03
    ADD CONSTRAINT audit_logs_2026_03_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_04 audit_logs_2026_04_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_04
    ADD CONSTRAINT audit_logs_2026_04_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_05 audit_logs_2026_05_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_05
    ADD CONSTRAINT audit_logs_2026_05_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_06 audit_logs_2026_06_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_06
    ADD CONSTRAINT audit_logs_2026_06_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_07 audit_logs_2026_07_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_07
    ADD CONSTRAINT audit_logs_2026_07_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_08 audit_logs_2026_08_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_08
    ADD CONSTRAINT audit_logs_2026_08_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_09 audit_logs_2026_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_09
    ADD CONSTRAINT audit_logs_2026_09_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_10 audit_logs_2026_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_10
    ADD CONSTRAINT audit_logs_2026_10_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_11 audit_logs_2026_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_11
    ADD CONSTRAINT audit_logs_2026_11_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_2026_12 audit_logs_2026_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_2026_12
    ADD CONSTRAINT audit_logs_2026_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_logs_default audit_logs_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs_default
    ADD CONSTRAINT audit_logs_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: configuration_audit_logs configuration_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_audit_logs
    ADD CONSTRAINT configuration_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: configuration_definitions configuration_definitions_configuration_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_definitions
    ADD CONSTRAINT configuration_definitions_configuration_key_key UNIQUE (configuration_key);


--
-- Name: configuration_definitions configuration_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_definitions
    ADD CONSTRAINT configuration_definitions_pkey PRIMARY KEY (id);


--
-- Name: configuration_versions configuration_published_periods_do_not_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_published_periods_do_not_overlap EXCLUDE USING gist (definition_id WITH =, scope WITH =, COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid) WITH =, COALESCE(tier_id, '00000000-0000-0000-0000-000000000000'::uuid) WITH =, tstzrange(effective_from, effective_until, '[)'::text) WITH &&) WHERE (((status)::text = 'PUBLISHED'::text));


--
-- Name: configuration_versions configuration_versions_approval_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_approval_id_key UNIQUE (approval_id);


--
-- Name: configuration_versions configuration_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_pkey PRIMARY KEY (id);


--
-- Name: data_access_logs data_access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_access_logs
    ADD CONSTRAINT data_access_logs_pkey PRIMARY KEY (id);


--
-- Name: feature_modules feature_modules_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_modules
    ADD CONSTRAINT feature_modules_code_key UNIQUE (code);


--
-- Name: feature_modules feature_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_modules
    ADD CONSTRAINT feature_modules_pkey PRIMARY KEY (id);


--
-- Name: feature_usage_limits feature_usage_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_usage_limits
    ADD CONSTRAINT feature_usage_limits_pkey PRIMARY KEY (id);


--
-- Name: features features_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_code_key UNIQUE (code);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: idempotency_keys idempotency_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys
    ADD CONSTRAINT idempotency_keys_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2025_09 idempotency_keys_2025_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_09
    ADD CONSTRAINT idempotency_keys_2025_09_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys uq_idempotency_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys
    ADD CONSTRAINT uq_idempotency_key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2025_09 idempotency_keys_2025_09_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_09
    ADD CONSTRAINT idempotency_keys_2025_09_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2025_10 idempotency_keys_2025_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_10
    ADD CONSTRAINT idempotency_keys_2025_10_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2025_10 idempotency_keys_2025_10_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_10
    ADD CONSTRAINT idempotency_keys_2025_10_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2025_11 idempotency_keys_2025_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_11
    ADD CONSTRAINT idempotency_keys_2025_11_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2025_11 idempotency_keys_2025_11_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_11
    ADD CONSTRAINT idempotency_keys_2025_11_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2025_12 idempotency_keys_2025_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_12
    ADD CONSTRAINT idempotency_keys_2025_12_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2025_12 idempotency_keys_2025_12_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2025_12
    ADD CONSTRAINT idempotency_keys_2025_12_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_01 idempotency_keys_2026_01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_01
    ADD CONSTRAINT idempotency_keys_2026_01_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_01 idempotency_keys_2026_01_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_01
    ADD CONSTRAINT idempotency_keys_2026_01_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_02 idempotency_keys_2026_02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_02
    ADD CONSTRAINT idempotency_keys_2026_02_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_02 idempotency_keys_2026_02_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_02
    ADD CONSTRAINT idempotency_keys_2026_02_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_03 idempotency_keys_2026_03_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_03
    ADD CONSTRAINT idempotency_keys_2026_03_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_03 idempotency_keys_2026_03_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_03
    ADD CONSTRAINT idempotency_keys_2026_03_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_04 idempotency_keys_2026_04_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_04
    ADD CONSTRAINT idempotency_keys_2026_04_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_04 idempotency_keys_2026_04_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_04
    ADD CONSTRAINT idempotency_keys_2026_04_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_05 idempotency_keys_2026_05_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_05
    ADD CONSTRAINT idempotency_keys_2026_05_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_05 idempotency_keys_2026_05_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_05
    ADD CONSTRAINT idempotency_keys_2026_05_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_06 idempotency_keys_2026_06_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_06
    ADD CONSTRAINT idempotency_keys_2026_06_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_06 idempotency_keys_2026_06_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_06
    ADD CONSTRAINT idempotency_keys_2026_06_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_07 idempotency_keys_2026_07_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_07
    ADD CONSTRAINT idempotency_keys_2026_07_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_07 idempotency_keys_2026_07_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_07
    ADD CONSTRAINT idempotency_keys_2026_07_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_08 idempotency_keys_2026_08_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_08
    ADD CONSTRAINT idempotency_keys_2026_08_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_08 idempotency_keys_2026_08_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_08
    ADD CONSTRAINT idempotency_keys_2026_08_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_09 idempotency_keys_2026_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_09
    ADD CONSTRAINT idempotency_keys_2026_09_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_09 idempotency_keys_2026_09_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_09
    ADD CONSTRAINT idempotency_keys_2026_09_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_10 idempotency_keys_2026_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_10
    ADD CONSTRAINT idempotency_keys_2026_10_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_10 idempotency_keys_2026_10_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_10
    ADD CONSTRAINT idempotency_keys_2026_10_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_11 idempotency_keys_2026_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_11
    ADD CONSTRAINT idempotency_keys_2026_11_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_11 idempotency_keys_2026_11_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_11
    ADD CONSTRAINT idempotency_keys_2026_11_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_2026_12 idempotency_keys_2026_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_12
    ADD CONSTRAINT idempotency_keys_2026_12_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_2026_12 idempotency_keys_2026_12_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_2026_12
    ADD CONSTRAINT idempotency_keys_2026_12_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: idempotency_keys_default idempotency_keys_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_default
    ADD CONSTRAINT idempotency_keys_default_pkey PRIMARY KEY (id, expires_at);


--
-- Name: idempotency_keys_default idempotency_keys_default_tenant_id_idempotency_key_expires__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys_default
    ADD CONSTRAINT idempotency_keys_default_tenant_id_idempotency_key_expires__key UNIQUE (tenant_id, idempotency_key, expires_at);


--
-- Name: inbox_events inbox_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_events
    ADD CONSTRAINT inbox_events_pkey PRIMARY KEY (id);


--
-- Name: operation_actions operation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_actions
    ADD CONSTRAINT operation_actions_pkey PRIMARY KEY (id);


--
-- Name: operation_approvals operation_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_approvals
    ADD CONSTRAINT operation_approvals_pkey PRIMARY KEY (id);


--
-- Name: operation_attachments operation_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_attachments
    ADD CONSTRAINT operation_attachments_pkey PRIMARY KEY (id);


--
-- Name: operation_comments operation_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_comments
    ADD CONSTRAINT operation_comments_pkey PRIMARY KEY (id);


--
-- Name: operation_requests operation_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_requests
    ADD CONSTRAINT operation_requests_pkey PRIMARY KEY (id);


--
-- Name: outbox_event_attempts outbox_event_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_event_attempts
    ADD CONSTRAINT outbox_event_attempts_pkey PRIMARY KEY (id);


--
-- Name: outbox_events outbox_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events
    ADD CONSTRAINT outbox_events_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2025_09 outbox_events_2025_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2025_09
    ADD CONSTRAINT outbox_events_2025_09_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2025_10 outbox_events_2025_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2025_10
    ADD CONSTRAINT outbox_events_2025_10_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2025_11 outbox_events_2025_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2025_11
    ADD CONSTRAINT outbox_events_2025_11_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2025_12 outbox_events_2025_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2025_12
    ADD CONSTRAINT outbox_events_2025_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_01 outbox_events_2026_01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_01
    ADD CONSTRAINT outbox_events_2026_01_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_02 outbox_events_2026_02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_02
    ADD CONSTRAINT outbox_events_2026_02_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_03 outbox_events_2026_03_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_03
    ADD CONSTRAINT outbox_events_2026_03_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_04 outbox_events_2026_04_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_04
    ADD CONSTRAINT outbox_events_2026_04_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_05 outbox_events_2026_05_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_05
    ADD CONSTRAINT outbox_events_2026_05_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_06 outbox_events_2026_06_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_06
    ADD CONSTRAINT outbox_events_2026_06_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_07 outbox_events_2026_07_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_07
    ADD CONSTRAINT outbox_events_2026_07_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_08 outbox_events_2026_08_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_08
    ADD CONSTRAINT outbox_events_2026_08_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_09 outbox_events_2026_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_09
    ADD CONSTRAINT outbox_events_2026_09_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_10 outbox_events_2026_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_10
    ADD CONSTRAINT outbox_events_2026_10_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_11 outbox_events_2026_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_11
    ADD CONSTRAINT outbox_events_2026_11_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_2026_12 outbox_events_2026_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_2026_12
    ADD CONSTRAINT outbox_events_2026_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: outbox_events_default outbox_events_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_events_default
    ADD CONSTRAINT outbox_events_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: provider_capabilities pk_provider_capabilities; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capabilities
    ADD CONSTRAINT pk_provider_capabilities PRIMARY KEY (id);


--
-- Name: provider_capability_availability_history provider_capability_availability_history_approval_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capability_availability_history
    ADD CONSTRAINT provider_capability_availability_history_approval_id_key UNIQUE (approval_id);


--
-- Name: provider_capability_availability_history provider_capability_availability_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capability_availability_history
    ADD CONSTRAINT provider_capability_availability_history_pkey PRIMARY KEY (id);


--
-- Name: provider_catalog provider_catalog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_catalog
    ADD CONSTRAINT provider_catalog_pkey PRIMARY KEY (provider_code);


--
-- Name: reconciliation_actions reconciliation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_actions
    ADD CONSTRAINT reconciliation_actions_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_exceptions reconciliation_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_exceptions
    ADD CONSTRAINT reconciliation_exceptions_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_items reconciliation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_items
    ADD CONSTRAINT reconciliation_items_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_jobs reconciliation_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_jobs
    ADD CONSTRAINT reconciliation_jobs_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_runs reconciliation_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_runs
    ADD CONSTRAINT reconciliation_runs_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_runs reconciliation_runs_run_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_runs
    ADD CONSTRAINT reconciliation_runs_run_reference_key UNIQUE (run_reference);


--
-- Name: security_events security_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_events
    ADD CONSTRAINT security_events_pkey PRIMARY KEY (id);


--
-- Name: support_categories support_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_pkey PRIMARY KEY (id);


--
-- Name: support_ticket_assignments support_ticket_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_assignments
    ADD CONSTRAINT support_ticket_assignments_pkey PRIMARY KEY (id);


--
-- Name: support_ticket_events support_ticket_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_events
    ADD CONSTRAINT support_ticket_events_pkey PRIMARY KEY (id);


--
-- Name: support_ticket_messages support_ticket_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_messages
    ADD CONSTRAINT support_ticket_messages_pkey PRIMARY KEY (id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- Name: system_configurations system_configurations_configuration_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configurations
    ADD CONSTRAINT system_configurations_configuration_key_key UNIQUE (configuration_key);


--
-- Name: system_configurations system_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configurations
    ADD CONSTRAINT system_configurations_pkey PRIMARY KEY (id);


--
-- Name: tenant_api_credentials tenant_api_credentials_client_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_api_credentials
    ADD CONSTRAINT tenant_api_credentials_client_id_key UNIQUE (client_id);


--
-- Name: tenant_api_credentials tenant_api_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_api_credentials
    ADD CONSTRAINT tenant_api_credentials_pkey PRIMARY KEY (id);


--
-- Name: tenant_commercial_agreements tenant_commercial_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_commercial_agreements
    ADD CONSTRAINT tenant_commercial_agreements_pkey PRIMARY KEY (id);


--
-- Name: tenant_configuration_publications tenant_configuration_publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_configuration_publications
    ADD CONSTRAINT tenant_configuration_publications_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenant_configurations tenant_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_configurations
    ADD CONSTRAINT tenant_configurations_pkey PRIMARY KEY (id);


--
-- Name: tenant_domains tenant_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_domains
    ADD CONSTRAINT tenant_domains_pkey PRIMARY KEY (id);


--
-- Name: tenant_feature_overrides tenant_feature_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_feature_overrides
    ADD CONSTRAINT tenant_feature_overrides_pkey PRIMARY KEY (id);


--
-- Name: tenant_feature_usage tenant_feature_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_feature_usage
    ADD CONSTRAINT tenant_feature_usage_pkey PRIMARY KEY (id);


--
-- Name: tenant_profiles tenant_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_profiles
    ADD CONSTRAINT tenant_profiles_pkey PRIMARY KEY (id);


--
-- Name: tenant_profiles tenant_profiles_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_profiles
    ADD CONSTRAINT tenant_profiles_tenant_id_key UNIQUE (tenant_id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_approval_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_approval_id_key UNIQUE (approval_id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_pkey PRIMARY KEY (id);


--
-- Name: tenant_provider_selections tenant_provider_selections_approval_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_approval_id_key UNIQUE (approval_id);


--
-- Name: tenant_provider_selections tenant_provider_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_pkey PRIMARY KEY (id);


--
-- Name: tenant_revenue_settlement_configuration_history tenant_revenue_settlement_configuration_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configuration_history
    ADD CONSTRAINT tenant_revenue_settlement_configuration_history_pkey PRIMARY KEY (id);


--
-- Name: tenant_revenue_settlement_configurations tenant_revenue_settlement_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configurations
    ADD CONSTRAINT tenant_revenue_settlement_configurations_pkey PRIMARY KEY (id);


--
-- Name: tenant_revenue_share_rule_history tenant_revenue_share_rule_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rule_history
    ADD CONSTRAINT tenant_revenue_share_rule_history_pkey PRIMARY KEY (id);


--
-- Name: tenant_revenue_share_rules tenant_revenue_share_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rules
    ADD CONSTRAINT tenant_revenue_share_rules_pkey PRIMARY KEY (id);


--
-- Name: tenant_revenue_share_tiers tenant_revenue_share_tiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_tiers
    ADD CONSTRAINT tenant_revenue_share_tiers_pkey PRIMARY KEY (id);


--
-- Name: tenant_service_configurations tenant_service_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_service_configurations
    ADD CONSTRAINT tenant_service_configurations_pkey PRIMARY KEY (id);


--
-- Name: tenant_settings tenant_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT tenant_settings_pkey PRIMARY KEY (id);


--
-- Name: tenant_settings tenant_settings_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT tenant_settings_tenant_id_key UNIQUE (tenant_id);


--
-- Name: tenant_status_history tenant_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_status_history
    ADD CONSTRAINT tenant_status_history_pkey PRIMARY KEY (id);


--
-- Name: tenant_tiers tenant_tiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_tiers
    ADD CONSTRAINT tenant_tiers_pkey PRIMARY KEY (id);


--
-- Name: tenant_webhooks tenant_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_webhooks
    ADD CONSTRAINT tenant_webhooks_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_tenant_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_tenant_code_key UNIQUE (tenant_code);


--
-- Name: tier_features tier_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tier_features
    ADD CONSTRAINT tier_features_pkey PRIMARY KEY (id);


--
-- Name: admin_user_roles uq_admin_user_role; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT uq_admin_user_role UNIQUE (admin_user_id, role_id);


--
-- Name: configuration_versions uq_configuration_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT uq_configuration_version UNIQUE (definition_id, scope, tenant_id, tier_id, version);


--
-- Name: inbox_events uq_inbox_source_event; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_events
    ADD CONSTRAINT uq_inbox_source_event UNIQUE (source_service, event_id);


--
-- Name: operation_requests uq_operation_reference; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_requests
    ADD CONSTRAINT uq_operation_reference UNIQUE (tenant_id, operation_reference);


--
-- Name: outbox_event_attempts uq_outbox_attempt; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_event_attempts
    ADD CONSTRAINT uq_outbox_attempt UNIQUE (outbox_event_id, attempt_number);


--
-- Name: admin_permissions uq_permission_resource_action; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT uq_permission_resource_action UNIQUE (resource, action);


--
-- Name: tenant_revenue_share_rule_history uq_revenue_share_rule_history_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rule_history
    ADD CONSTRAINT uq_revenue_share_rule_history_version UNIQUE (revenue_share_rule_id, version_number);


--
-- Name: admin_role_permissions uq_role_permission; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions
    ADD CONSTRAINT uq_role_permission UNIQUE (role_id, permission_id);


--
-- Name: tenant_revenue_settlement_configuration_history uq_settlement_configuration_history_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configuration_history
    ADD CONSTRAINT uq_settlement_configuration_history_version UNIQUE (settlement_configuration_id, version_number);


--
-- Name: support_tickets uq_support_ticket_reference; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT uq_support_ticket_reference UNIQUE (tenant_id, ticket_reference);


--
-- Name: tenant_commercial_agreements uq_tenant_commercial_agreement_reference; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_commercial_agreements
    ADD CONSTRAINT uq_tenant_commercial_agreement_reference UNIQUE (tenant_id, agreement_reference, agreement_version);


--
-- Name: tenant_configurations uq_tenant_configuration; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_configurations
    ADD CONSTRAINT uq_tenant_configuration UNIQUE (tenant_id, configuration_key);


--
-- Name: tenant_domains uq_tenant_domain; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_domains
    ADD CONSTRAINT uq_tenant_domain UNIQUE (domain);


--
-- Name: feature_usage_limits uq_tenant_feature_limit; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_usage_limits
    ADD CONSTRAINT uq_tenant_feature_limit UNIQUE (tenant_id, feature_id, limit_name);


--
-- Name: tenant_feature_usage uq_tenant_feature_usage; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_feature_usage
    ADD CONSTRAINT uq_tenant_feature_usage UNIQUE (tenant_id, feature_id, usage_date);


--
-- Name: tenant_provider_selection_history uq_tenant_provider_history_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT uq_tenant_provider_history_version UNIQUE (selection_id, version);


--
-- Name: tenant_revenue_settlement_configurations uq_tenant_revenue_settlement_configuration; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configurations
    ADD CONSTRAINT uq_tenant_revenue_settlement_configuration UNIQUE (tenant_id, configuration_name);


--
-- Name: tenant_revenue_share_rules uq_tenant_revenue_share_rule_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rules
    ADD CONSTRAINT uq_tenant_revenue_share_rule_code UNIQUE (tenant_id, rule_code);


--
-- Name: tenant_revenue_share_tiers uq_tenant_revenue_share_tier_order; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_tiers
    ADD CONSTRAINT uq_tenant_revenue_share_tier_order UNIQUE (revenue_share_rule_id, tier_order);


--
-- Name: tier_features uq_tier_feature; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tier_features
    ADD CONSTRAINT uq_tier_feature UNIQUE (tier_id, feature_id);


--
-- Name: idx_audit_logs_actor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_actor ON ONLY public.audit_logs USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2025_09_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_09_actor_id_created_at_idx ON public.audit_logs_2025_09 USING btree (actor_id, created_at DESC);


--
-- Name: brin_audit_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX brin_audit_logs_created_at ON ONLY public.audit_logs USING brin (created_at);


--
-- Name: audit_logs_2025_09_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_09_created_at_idx ON public.audit_logs_2025_09 USING brin (created_at);


--
-- Name: idx_audit_logs_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_resource ON ONLY public.audit_logs USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2025_09_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_09_resource_type_resource_id_created_at_idx ON public.audit_logs_2025_09 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: idx_audit_logs_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_tenant ON ONLY public.audit_logs USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2025_09_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_09_tenant_id_created_at_idx ON public.audit_logs_2025_09 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2025_10_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_10_actor_id_created_at_idx ON public.audit_logs_2025_10 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2025_10_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_10_created_at_idx ON public.audit_logs_2025_10 USING brin (created_at);


--
-- Name: audit_logs_2025_10_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_10_resource_type_resource_id_created_at_idx ON public.audit_logs_2025_10 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2025_10_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_10_tenant_id_created_at_idx ON public.audit_logs_2025_10 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2025_11_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_11_actor_id_created_at_idx ON public.audit_logs_2025_11 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2025_11_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_11_created_at_idx ON public.audit_logs_2025_11 USING brin (created_at);


--
-- Name: audit_logs_2025_11_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_11_resource_type_resource_id_created_at_idx ON public.audit_logs_2025_11 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2025_11_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_11_tenant_id_created_at_idx ON public.audit_logs_2025_11 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2025_12_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_12_actor_id_created_at_idx ON public.audit_logs_2025_12 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2025_12_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_12_created_at_idx ON public.audit_logs_2025_12 USING brin (created_at);


--
-- Name: audit_logs_2025_12_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_12_resource_type_resource_id_created_at_idx ON public.audit_logs_2025_12 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2025_12_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2025_12_tenant_id_created_at_idx ON public.audit_logs_2025_12 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_01_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_01_actor_id_created_at_idx ON public.audit_logs_2026_01 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_01_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_01_created_at_idx ON public.audit_logs_2026_01 USING brin (created_at);


--
-- Name: audit_logs_2026_01_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_01_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_01 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_01_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_01_tenant_id_created_at_idx ON public.audit_logs_2026_01 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_02_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_02_actor_id_created_at_idx ON public.audit_logs_2026_02 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_02_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_02_created_at_idx ON public.audit_logs_2026_02 USING brin (created_at);


--
-- Name: audit_logs_2026_02_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_02_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_02 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_02_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_02_tenant_id_created_at_idx ON public.audit_logs_2026_02 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_03_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_03_actor_id_created_at_idx ON public.audit_logs_2026_03 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_03_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_03_created_at_idx ON public.audit_logs_2026_03 USING brin (created_at);


--
-- Name: audit_logs_2026_03_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_03_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_03 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_03_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_03_tenant_id_created_at_idx ON public.audit_logs_2026_03 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_04_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_04_actor_id_created_at_idx ON public.audit_logs_2026_04 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_04_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_04_created_at_idx ON public.audit_logs_2026_04 USING brin (created_at);


--
-- Name: audit_logs_2026_04_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_04_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_04 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_04_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_04_tenant_id_created_at_idx ON public.audit_logs_2026_04 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_05_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_05_actor_id_created_at_idx ON public.audit_logs_2026_05 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_05_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_05_created_at_idx ON public.audit_logs_2026_05 USING brin (created_at);


--
-- Name: audit_logs_2026_05_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_05_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_05 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_05_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_05_tenant_id_created_at_idx ON public.audit_logs_2026_05 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_06_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_06_actor_id_created_at_idx ON public.audit_logs_2026_06 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_06_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_06_created_at_idx ON public.audit_logs_2026_06 USING brin (created_at);


--
-- Name: audit_logs_2026_06_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_06_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_06 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_06_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_06_tenant_id_created_at_idx ON public.audit_logs_2026_06 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_07_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_07_actor_id_created_at_idx ON public.audit_logs_2026_07 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_07_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_07_created_at_idx ON public.audit_logs_2026_07 USING brin (created_at);


--
-- Name: audit_logs_2026_07_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_07_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_07 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_07_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_07_tenant_id_created_at_idx ON public.audit_logs_2026_07 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_08_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_08_actor_id_created_at_idx ON public.audit_logs_2026_08 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_08_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_08_created_at_idx ON public.audit_logs_2026_08 USING brin (created_at);


--
-- Name: audit_logs_2026_08_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_08_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_08 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_08_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_08_tenant_id_created_at_idx ON public.audit_logs_2026_08 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_09_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_09_actor_id_created_at_idx ON public.audit_logs_2026_09 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_09_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_09_created_at_idx ON public.audit_logs_2026_09 USING brin (created_at);


--
-- Name: audit_logs_2026_09_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_09_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_09 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_09_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_09_tenant_id_created_at_idx ON public.audit_logs_2026_09 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_10_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_10_actor_id_created_at_idx ON public.audit_logs_2026_10 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_10_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_10_created_at_idx ON public.audit_logs_2026_10 USING brin (created_at);


--
-- Name: audit_logs_2026_10_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_10_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_10 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_10_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_10_tenant_id_created_at_idx ON public.audit_logs_2026_10 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_11_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_11_actor_id_created_at_idx ON public.audit_logs_2026_11 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_11_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_11_created_at_idx ON public.audit_logs_2026_11 USING brin (created_at);


--
-- Name: audit_logs_2026_11_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_11_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_11 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_11_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_11_tenant_id_created_at_idx ON public.audit_logs_2026_11 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_2026_12_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_12_actor_id_created_at_idx ON public.audit_logs_2026_12 USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_2026_12_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_12_created_at_idx ON public.audit_logs_2026_12 USING brin (created_at);


--
-- Name: audit_logs_2026_12_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_12_resource_type_resource_id_created_at_idx ON public.audit_logs_2026_12 USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_2026_12_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_2026_12_tenant_id_created_at_idx ON public.audit_logs_2026_12 USING btree (tenant_id, created_at DESC);


--
-- Name: audit_logs_default_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_default_actor_id_created_at_idx ON public.audit_logs_default USING btree (actor_id, created_at DESC);


--
-- Name: audit_logs_default_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_default_created_at_idx ON public.audit_logs_default USING brin (created_at);


--
-- Name: audit_logs_default_resource_type_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_default_resource_type_resource_id_created_at_idx ON public.audit_logs_default USING btree (resource_type, resource_id, created_at DESC);


--
-- Name: audit_logs_default_tenant_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_default_tenant_id_created_at_idx ON public.audit_logs_default USING btree (tenant_id, created_at DESC);


--
-- Name: brin_idempotency_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX brin_idempotency_expires_at ON ONLY public.idempotency_keys USING brin (expires_at);


--
-- Name: brin_outbox_events_available_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX brin_outbox_events_available_at ON ONLY public.outbox_events USING brin (available_at);


--
-- Name: idx_idempotency_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_idempotency_expiry ON ONLY public.idempotency_keys USING btree (expires_at);


--
-- Name: idempotency_keys_2025_09_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_09_expires_at_idx ON public.idempotency_keys_2025_09 USING btree (expires_at);


--
-- Name: idempotency_keys_2025_09_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_09_expires_at_idx1 ON public.idempotency_keys_2025_09 USING brin (expires_at);


--
-- Name: idempotency_keys_2025_10_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_10_expires_at_idx ON public.idempotency_keys_2025_10 USING btree (expires_at);


--
-- Name: idempotency_keys_2025_10_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_10_expires_at_idx1 ON public.idempotency_keys_2025_10 USING brin (expires_at);


--
-- Name: idempotency_keys_2025_11_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_11_expires_at_idx ON public.idempotency_keys_2025_11 USING btree (expires_at);


--
-- Name: idempotency_keys_2025_11_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_11_expires_at_idx1 ON public.idempotency_keys_2025_11 USING brin (expires_at);


--
-- Name: idempotency_keys_2025_12_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_12_expires_at_idx ON public.idempotency_keys_2025_12 USING btree (expires_at);


--
-- Name: idempotency_keys_2025_12_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2025_12_expires_at_idx1 ON public.idempotency_keys_2025_12 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_01_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_01_expires_at_idx ON public.idempotency_keys_2026_01 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_01_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_01_expires_at_idx1 ON public.idempotency_keys_2026_01 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_02_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_02_expires_at_idx ON public.idempotency_keys_2026_02 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_02_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_02_expires_at_idx1 ON public.idempotency_keys_2026_02 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_03_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_03_expires_at_idx ON public.idempotency_keys_2026_03 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_03_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_03_expires_at_idx1 ON public.idempotency_keys_2026_03 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_04_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_04_expires_at_idx ON public.idempotency_keys_2026_04 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_04_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_04_expires_at_idx1 ON public.idempotency_keys_2026_04 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_05_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_05_expires_at_idx ON public.idempotency_keys_2026_05 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_05_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_05_expires_at_idx1 ON public.idempotency_keys_2026_05 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_06_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_06_expires_at_idx ON public.idempotency_keys_2026_06 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_06_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_06_expires_at_idx1 ON public.idempotency_keys_2026_06 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_07_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_07_expires_at_idx ON public.idempotency_keys_2026_07 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_07_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_07_expires_at_idx1 ON public.idempotency_keys_2026_07 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_08_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_08_expires_at_idx ON public.idempotency_keys_2026_08 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_08_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_08_expires_at_idx1 ON public.idempotency_keys_2026_08 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_09_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_09_expires_at_idx ON public.idempotency_keys_2026_09 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_09_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_09_expires_at_idx1 ON public.idempotency_keys_2026_09 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_10_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_10_expires_at_idx ON public.idempotency_keys_2026_10 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_10_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_10_expires_at_idx1 ON public.idempotency_keys_2026_10 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_11_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_11_expires_at_idx ON public.idempotency_keys_2026_11 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_11_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_11_expires_at_idx1 ON public.idempotency_keys_2026_11 USING brin (expires_at);


--
-- Name: idempotency_keys_2026_12_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_12_expires_at_idx ON public.idempotency_keys_2026_12 USING btree (expires_at);


--
-- Name: idempotency_keys_2026_12_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_2026_12_expires_at_idx1 ON public.idempotency_keys_2026_12 USING brin (expires_at);


--
-- Name: idempotency_keys_default_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_default_expires_at_idx ON public.idempotency_keys_default USING btree (expires_at);


--
-- Name: idempotency_keys_default_expires_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_default_expires_at_idx1 ON public.idempotency_keys_default USING brin (expires_at);


--
-- Name: idx_admin_activity_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_activity_tenant ON public.admin_activity_logs USING btree (tenant_id, created_at DESC);


--
-- Name: idx_admin_login_attempts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_login_attempts_email ON public.admin_login_attempts USING btree (lower((email)::text), attempted_at DESC);


--
-- Name: idx_admin_roles_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_roles_tenant ON public.admin_roles USING btree (tenant_id);


--
-- Name: idx_admin_sessions_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_sessions_expiry ON public.admin_sessions USING btree (expires_at);


--
-- Name: idx_admin_sessions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_sessions_user ON public.admin_sessions USING btree (admin_user_id);


--
-- Name: idx_admin_user_roles_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_user_roles_role ON public.admin_user_roles USING btree (role_id);


--
-- Name: idx_admin_user_roles_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_user_roles_user ON public.admin_user_roles USING btree (admin_user_id);


--
-- Name: idx_admin_users_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_users_status ON public.admin_users USING btree (status);


--
-- Name: idx_admin_users_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_users_tenant ON public.admin_users USING btree (tenant_id);


--
-- Name: idx_available_provider_capabilities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_available_provider_capabilities ON public.provider_capabilities USING btree (capability, currency, provider_code) WHERE (is_enabled AND ((availability)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'DEGRADED'::character varying])::text[])));


--
-- Name: idx_commercial_agreements_tenant_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_commercial_agreements_tenant_status ON public.tenant_commercial_agreements USING btree (tenant_id, status, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_configuration_audit_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_configuration_audit_tenant ON public.configuration_audit_logs USING btree (tenant_id, changed_at DESC);


--
-- Name: idx_configuration_effective; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_configuration_effective ON public.configuration_versions USING btree (definition_id, scope, tenant_id, tier_id, effective_from DESC) WHERE ((status)::text = 'PUBLISHED'::text);


--
-- Name: idx_data_access_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_data_access_tenant ON public.data_access_logs USING btree (tenant_id, created_at DESC);


--
-- Name: idx_feature_usage_tenant_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feature_usage_tenant_date ON public.tenant_feature_usage USING btree (tenant_id, usage_date DESC);


--
-- Name: idx_features_module; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_features_module ON public.features USING btree (module_id);


--
-- Name: idx_features_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_features_status ON public.features USING btree (status);


--
-- Name: idx_inbox_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_pending ON public.inbox_events USING btree (status, next_attempt_at, received_at) WHERE (status = ANY (ARRAY['RECEIVED'::public.inbox_status_enum, 'FAILED'::public.inbox_status_enum]));


--
-- Name: idx_inbox_tenant_received; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_tenant_received ON public.inbox_events USING btree (tenant_id, received_at DESC);


--
-- Name: idx_operation_approvals_request; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_approvals_request ON public.operation_approvals USING btree (operation_request_id);


--
-- Name: idx_operation_consumed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_consumed ON public.operation_requests USING btree (consumed_by_service, consumed_at DESC) WHERE (status = 'CONSUMED'::public.operation_status_enum);


--
-- Name: idx_operation_pending_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_pending_expiry ON public.operation_requests USING btree (expires_at, tenant_id) WHERE (status = ANY (ARRAY['PENDING'::public.operation_status_enum, 'IN_REVIEW'::public.operation_status_enum]));


--
-- Name: idx_operation_requests_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_requests_resource ON public.operation_requests USING btree (resource_type, resource_id);


--
-- Name: idx_operation_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_requests_status ON public.operation_requests USING btree (tenant_id, status);


--
-- Name: idx_operation_requests_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operation_requests_tenant ON public.operation_requests USING btree (tenant_id, created_at DESC);


--
-- Name: idx_outbox_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outbox_aggregate ON ONLY public.outbox_events USING btree (aggregate_type, aggregate_id);


--
-- Name: idx_outbox_attempts_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outbox_attempts_event ON public.outbox_event_attempts USING btree (outbox_event_id, attempt_number);


--
-- Name: idx_outbox_correlation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outbox_correlation ON ONLY public.outbox_events USING btree (correlation_id);


--
-- Name: idx_outbox_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outbox_pending ON ONLY public.outbox_events USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: idx_reconciliation_actions_exception; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconciliation_actions_exception ON public.reconciliation_actions USING btree (reconciliation_exception_id);


--
-- Name: idx_reconciliation_exceptions_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconciliation_exceptions_tenant ON public.reconciliation_exceptions USING btree (tenant_id, status, created_at DESC);


--
-- Name: idx_reconciliation_items_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconciliation_items_run ON public.reconciliation_items USING btree (reconciliation_run_id);


--
-- Name: idx_reconciliation_items_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconciliation_items_status ON public.reconciliation_items USING btree (status);


--
-- Name: idx_reconciliation_runs_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconciliation_runs_job ON public.reconciliation_runs USING btree (reconciliation_job_id, created_at DESC);


--
-- Name: idx_revenue_settlement_config_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_settlement_config_active ON public.tenant_revenue_settlement_configurations USING btree (tenant_id, is_active, effective_from DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_revenue_settlement_config_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_settlement_config_history ON public.tenant_revenue_settlement_configuration_history USING btree (settlement_configuration_id, version_number DESC);


--
-- Name: idx_revenue_share_rule_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_share_rule_history ON public.tenant_revenue_share_rule_history USING btree (revenue_share_rule_id, version_number DESC);


--
-- Name: idx_revenue_share_rules_basis; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_share_rules_basis ON public.tenant_revenue_share_rules USING btree (tenant_id, calculation_basis, status) WHERE (deleted_at IS NULL);


--
-- Name: idx_revenue_share_rules_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_share_rules_lookup ON public.tenant_revenue_share_rules USING btree (tenant_id, revenue_type, status, effective_from DESC, priority) WHERE (deleted_at IS NULL);


--
-- Name: idx_revenue_share_tiers_rule; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revenue_share_tiers_rule ON public.tenant_revenue_share_tiers USING btree (revenue_share_rule_id, tier_order);


--
-- Name: idx_security_events_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_security_events_tenant ON public.security_events USING btree (tenant_id, created_at DESC);


--
-- Name: idx_security_events_unresolved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_security_events_unresolved ON public.security_events USING btree (resolved, created_at DESC) WHERE (resolved = false);


--
-- Name: idx_support_events_ticket; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_events_ticket ON public.support_ticket_events USING btree (ticket_id, created_at);


--
-- Name: idx_support_messages_ticket; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_messages_ticket ON public.support_ticket_messages USING btree (ticket_id, created_at);


--
-- Name: idx_support_tickets_assigned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_assigned ON public.support_tickets USING btree (assigned_admin_id, status);


--
-- Name: idx_support_tickets_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_status ON public.support_tickets USING btree (tenant_id, status);


--
-- Name: idx_support_tickets_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_tenant ON public.support_tickets USING btree (tenant_id, created_at DESC);


--
-- Name: idx_tenant_api_credentials_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_api_credentials_tenant ON public.tenant_api_credentials USING btree (tenant_id);


--
-- Name: idx_tenant_configurations_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_configurations_tenant ON public.tenant_configurations USING btree (tenant_id);


--
-- Name: idx_tenant_domains_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_domains_tenant ON public.tenant_domains USING btree (tenant_id);


--
-- Name: idx_tenant_feature_overrides_feature; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_feature_overrides_feature ON public.tenant_feature_overrides USING btree (feature_id);


--
-- Name: idx_tenant_feature_overrides_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_feature_overrides_tenant ON public.tenant_feature_overrides USING btree (tenant_id);


--
-- Name: idx_tenant_provider_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_provider_history ON public.tenant_provider_selection_history USING btree (tenant_id, capability, currency, version DESC);


--
-- Name: idx_tenant_provider_resolution; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_provider_resolution ON public.tenant_provider_selections USING btree (tenant_id, capability, currency);


--
-- Name: idx_tenant_service_configurations_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_service_configurations_tenant ON public.tenant_service_configurations USING btree (tenant_id, service_code);


--
-- Name: idx_tenant_status_history_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_status_history_tenant ON public.tenant_status_history USING btree (tenant_id, changed_at DESC);


--
-- Name: idx_tenant_webhooks_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_webhooks_tenant ON public.tenant_webhooks USING btree (tenant_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenants_status ON public.tenants USING btree (status);


--
-- Name: idx_tenants_tier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenants_tier ON public.tenants USING btree (tier_id);


--
-- Name: idx_tenants_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenants_type ON public.tenants USING btree (tenant_type);


--
-- Name: idx_tier_features_feature; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tier_features_feature ON public.tier_features USING btree (feature_id);


--
-- Name: idx_tier_features_tier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tier_features_tier ON public.tier_features USING btree (tier_id);


--
-- Name: outbox_events_2025_09_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_09_aggregate_type_aggregate_id_idx ON public.outbox_events_2025_09 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2025_09_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_09_available_at_idx ON public.outbox_events_2025_09 USING brin (available_at);


--
-- Name: outbox_events_2025_09_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_09_correlation_id_idx ON public.outbox_events_2025_09 USING btree (correlation_id);


--
-- Name: outbox_events_2025_09_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_09_status_available_at_created_at_idx ON public.outbox_events_2025_09 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2025_10_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_10_aggregate_type_aggregate_id_idx ON public.outbox_events_2025_10 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2025_10_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_10_available_at_idx ON public.outbox_events_2025_10 USING brin (available_at);


--
-- Name: outbox_events_2025_10_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_10_correlation_id_idx ON public.outbox_events_2025_10 USING btree (correlation_id);


--
-- Name: outbox_events_2025_10_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_10_status_available_at_created_at_idx ON public.outbox_events_2025_10 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2025_11_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_11_aggregate_type_aggregate_id_idx ON public.outbox_events_2025_11 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2025_11_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_11_available_at_idx ON public.outbox_events_2025_11 USING brin (available_at);


--
-- Name: outbox_events_2025_11_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_11_correlation_id_idx ON public.outbox_events_2025_11 USING btree (correlation_id);


--
-- Name: outbox_events_2025_11_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_11_status_available_at_created_at_idx ON public.outbox_events_2025_11 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2025_12_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_12_aggregate_type_aggregate_id_idx ON public.outbox_events_2025_12 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2025_12_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_12_available_at_idx ON public.outbox_events_2025_12 USING brin (available_at);


--
-- Name: outbox_events_2025_12_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_12_correlation_id_idx ON public.outbox_events_2025_12 USING btree (correlation_id);


--
-- Name: outbox_events_2025_12_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2025_12_status_available_at_created_at_idx ON public.outbox_events_2025_12 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_01_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_01_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_01 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_01_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_01_available_at_idx ON public.outbox_events_2026_01 USING brin (available_at);


--
-- Name: outbox_events_2026_01_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_01_correlation_id_idx ON public.outbox_events_2026_01 USING btree (correlation_id);


--
-- Name: outbox_events_2026_01_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_01_status_available_at_created_at_idx ON public.outbox_events_2026_01 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_02_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_02_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_02 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_02_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_02_available_at_idx ON public.outbox_events_2026_02 USING brin (available_at);


--
-- Name: outbox_events_2026_02_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_02_correlation_id_idx ON public.outbox_events_2026_02 USING btree (correlation_id);


--
-- Name: outbox_events_2026_02_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_02_status_available_at_created_at_idx ON public.outbox_events_2026_02 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_03_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_03_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_03 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_03_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_03_available_at_idx ON public.outbox_events_2026_03 USING brin (available_at);


--
-- Name: outbox_events_2026_03_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_03_correlation_id_idx ON public.outbox_events_2026_03 USING btree (correlation_id);


--
-- Name: outbox_events_2026_03_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_03_status_available_at_created_at_idx ON public.outbox_events_2026_03 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_04_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_04_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_04 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_04_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_04_available_at_idx ON public.outbox_events_2026_04 USING brin (available_at);


--
-- Name: outbox_events_2026_04_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_04_correlation_id_idx ON public.outbox_events_2026_04 USING btree (correlation_id);


--
-- Name: outbox_events_2026_04_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_04_status_available_at_created_at_idx ON public.outbox_events_2026_04 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_05_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_05_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_05 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_05_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_05_available_at_idx ON public.outbox_events_2026_05 USING brin (available_at);


--
-- Name: outbox_events_2026_05_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_05_correlation_id_idx ON public.outbox_events_2026_05 USING btree (correlation_id);


--
-- Name: outbox_events_2026_05_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_05_status_available_at_created_at_idx ON public.outbox_events_2026_05 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_06_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_06_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_06 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_06_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_06_available_at_idx ON public.outbox_events_2026_06 USING brin (available_at);


--
-- Name: outbox_events_2026_06_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_06_correlation_id_idx ON public.outbox_events_2026_06 USING btree (correlation_id);


--
-- Name: outbox_events_2026_06_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_06_status_available_at_created_at_idx ON public.outbox_events_2026_06 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_07_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_07_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_07 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_07_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_07_available_at_idx ON public.outbox_events_2026_07 USING brin (available_at);


--
-- Name: outbox_events_2026_07_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_07_correlation_id_idx ON public.outbox_events_2026_07 USING btree (correlation_id);


--
-- Name: outbox_events_2026_07_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_07_status_available_at_created_at_idx ON public.outbox_events_2026_07 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_08_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_08_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_08 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_08_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_08_available_at_idx ON public.outbox_events_2026_08 USING brin (available_at);


--
-- Name: outbox_events_2026_08_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_08_correlation_id_idx ON public.outbox_events_2026_08 USING btree (correlation_id);


--
-- Name: outbox_events_2026_08_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_08_status_available_at_created_at_idx ON public.outbox_events_2026_08 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_09_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_09_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_09 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_09_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_09_available_at_idx ON public.outbox_events_2026_09 USING brin (available_at);


--
-- Name: outbox_events_2026_09_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_09_correlation_id_idx ON public.outbox_events_2026_09 USING btree (correlation_id);


--
-- Name: outbox_events_2026_09_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_09_status_available_at_created_at_idx ON public.outbox_events_2026_09 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_10_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_10_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_10 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_10_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_10_available_at_idx ON public.outbox_events_2026_10 USING brin (available_at);


--
-- Name: outbox_events_2026_10_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_10_correlation_id_idx ON public.outbox_events_2026_10 USING btree (correlation_id);


--
-- Name: outbox_events_2026_10_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_10_status_available_at_created_at_idx ON public.outbox_events_2026_10 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_11_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_11_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_11 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_11_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_11_available_at_idx ON public.outbox_events_2026_11 USING brin (available_at);


--
-- Name: outbox_events_2026_11_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_11_correlation_id_idx ON public.outbox_events_2026_11 USING btree (correlation_id);


--
-- Name: outbox_events_2026_11_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_11_status_available_at_created_at_idx ON public.outbox_events_2026_11 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_2026_12_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_12_aggregate_type_aggregate_id_idx ON public.outbox_events_2026_12 USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_2026_12_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_12_available_at_idx ON public.outbox_events_2026_12 USING brin (available_at);


--
-- Name: outbox_events_2026_12_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_12_correlation_id_idx ON public.outbox_events_2026_12 USING btree (correlation_id);


--
-- Name: outbox_events_2026_12_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_2026_12_status_available_at_created_at_idx ON public.outbox_events_2026_12 USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: outbox_events_default_aggregate_type_aggregate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_default_aggregate_type_aggregate_id_idx ON public.outbox_events_default USING btree (aggregate_type, aggregate_id);


--
-- Name: outbox_events_default_available_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_default_available_at_idx ON public.outbox_events_default USING brin (available_at);


--
-- Name: outbox_events_default_correlation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_default_correlation_id_idx ON public.outbox_events_default USING btree (correlation_id);


--
-- Name: outbox_events_default_status_available_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX outbox_events_default_status_available_at_created_at_idx ON public.outbox_events_default USING btree (status, available_at, created_at) WHERE (status = ANY (ARRAY['PENDING'::public.outbox_status_enum, 'FAILED'::public.outbox_status_enum]));


--
-- Name: uq_admin_email_global; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_admin_email_global ON public.admin_users USING btree (lower((email)::text)) WHERE (deleted_at IS NULL);


--
-- Name: uq_admin_role_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_admin_role_code ON public.admin_roles USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), lower((code)::text)) WHERE (deleted_at IS NULL);


--
-- Name: uq_configuration_version_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_configuration_version_scope ON public.configuration_versions USING btree (definition_id, scope, COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(tier_id, '00000000-0000-0000-0000-000000000000'::uuid), version);


--
-- Name: uq_operation_approval_checker; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_operation_approval_checker ON public.operation_approvals USING btree (operation_request_id, approver_id);


--
-- Name: uq_operation_consumption_idempotency; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_operation_consumption_idempotency ON public.operation_requests USING btree (consumed_by_service, consumption_idempotency_key) WHERE (consumption_idempotency_key IS NOT NULL);


--
-- Name: uq_provider_capability_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_provider_capability_scope ON public.provider_capabilities USING btree (provider_code, capability, COALESCE(currency, '---'::bpchar));


--
-- Name: uq_reconciliation_job_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_reconciliation_job_code ON public.reconciliation_jobs USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), lower((job_code)::text)) WHERE (deleted_at IS NULL);


--
-- Name: uq_tenant_provider_selection_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_tenant_provider_selection_scope ON public.tenant_provider_selections USING btree (tenant_id, capability, COALESCE(currency, '---'::bpchar));


--
-- Name: uq_tenant_service_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_tenant_service_provider ON public.tenant_service_configurations USING btree (tenant_id, service_code, provider_code, environment) WHERE (deleted_at IS NULL);


--
-- Name: audit_logs_2025_09_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2025_09_actor_id_created_at_idx;


--
-- Name: audit_logs_2025_09_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2025_09_created_at_idx;


--
-- Name: audit_logs_2025_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2025_09_pkey;


--
-- Name: audit_logs_2025_09_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2025_09_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2025_09_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2025_09_tenant_id_created_at_idx;


--
-- Name: audit_logs_2025_10_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2025_10_actor_id_created_at_idx;


--
-- Name: audit_logs_2025_10_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2025_10_created_at_idx;


--
-- Name: audit_logs_2025_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2025_10_pkey;


--
-- Name: audit_logs_2025_10_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2025_10_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2025_10_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2025_10_tenant_id_created_at_idx;


--
-- Name: audit_logs_2025_11_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2025_11_actor_id_created_at_idx;


--
-- Name: audit_logs_2025_11_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2025_11_created_at_idx;


--
-- Name: audit_logs_2025_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2025_11_pkey;


--
-- Name: audit_logs_2025_11_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2025_11_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2025_11_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2025_11_tenant_id_created_at_idx;


--
-- Name: audit_logs_2025_12_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2025_12_actor_id_created_at_idx;


--
-- Name: audit_logs_2025_12_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2025_12_created_at_idx;


--
-- Name: audit_logs_2025_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2025_12_pkey;


--
-- Name: audit_logs_2025_12_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2025_12_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2025_12_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2025_12_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_01_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_01_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_01_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_01_created_at_idx;


--
-- Name: audit_logs_2026_01_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_01_pkey;


--
-- Name: audit_logs_2026_01_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_01_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_01_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_01_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_02_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_02_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_02_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_02_created_at_idx;


--
-- Name: audit_logs_2026_02_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_02_pkey;


--
-- Name: audit_logs_2026_02_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_02_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_02_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_02_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_03_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_03_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_03_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_03_created_at_idx;


--
-- Name: audit_logs_2026_03_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_03_pkey;


--
-- Name: audit_logs_2026_03_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_03_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_03_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_03_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_04_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_04_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_04_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_04_created_at_idx;


--
-- Name: audit_logs_2026_04_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_04_pkey;


--
-- Name: audit_logs_2026_04_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_04_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_04_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_04_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_05_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_05_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_05_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_05_created_at_idx;


--
-- Name: audit_logs_2026_05_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_05_pkey;


--
-- Name: audit_logs_2026_05_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_05_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_05_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_05_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_06_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_06_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_06_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_06_created_at_idx;


--
-- Name: audit_logs_2026_06_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_06_pkey;


--
-- Name: audit_logs_2026_06_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_06_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_06_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_06_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_07_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_07_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_07_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_07_created_at_idx;


--
-- Name: audit_logs_2026_07_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_07_pkey;


--
-- Name: audit_logs_2026_07_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_07_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_07_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_07_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_08_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_08_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_08_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_08_created_at_idx;


--
-- Name: audit_logs_2026_08_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_08_pkey;


--
-- Name: audit_logs_2026_08_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_08_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_08_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_08_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_09_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_09_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_09_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_09_created_at_idx;


--
-- Name: audit_logs_2026_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_09_pkey;


--
-- Name: audit_logs_2026_09_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_09_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_09_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_09_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_10_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_10_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_10_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_10_created_at_idx;


--
-- Name: audit_logs_2026_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_10_pkey;


--
-- Name: audit_logs_2026_10_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_10_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_10_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_10_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_11_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_11_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_11_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_11_created_at_idx;


--
-- Name: audit_logs_2026_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_11_pkey;


--
-- Name: audit_logs_2026_11_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_11_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_11_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_11_tenant_id_created_at_idx;


--
-- Name: audit_logs_2026_12_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_2026_12_actor_id_created_at_idx;


--
-- Name: audit_logs_2026_12_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_2026_12_created_at_idx;


--
-- Name: audit_logs_2026_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_2026_12_pkey;


--
-- Name: audit_logs_2026_12_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_2026_12_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_2026_12_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_2026_12_tenant_id_created_at_idx;


--
-- Name: audit_logs_default_actor_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_actor ATTACH PARTITION public.audit_logs_default_actor_id_created_at_idx;


--
-- Name: audit_logs_default_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_audit_logs_created_at ATTACH PARTITION public.audit_logs_default_created_at_idx;


--
-- Name: audit_logs_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_logs_pkey ATTACH PARTITION public.audit_logs_default_pkey;


--
-- Name: audit_logs_default_resource_type_resource_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_resource ATTACH PARTITION public.audit_logs_default_resource_type_resource_id_created_at_idx;


--
-- Name: audit_logs_default_tenant_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_logs_tenant ATTACH PARTITION public.audit_logs_default_tenant_id_created_at_idx;


--
-- Name: idempotency_keys_2025_09_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2025_09_expires_at_idx;


--
-- Name: idempotency_keys_2025_09_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2025_09_expires_at_idx1;


--
-- Name: idempotency_keys_2025_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2025_09_pkey;


--
-- Name: idempotency_keys_2025_09_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2025_09_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2025_10_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2025_10_expires_at_idx;


--
-- Name: idempotency_keys_2025_10_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2025_10_expires_at_idx1;


--
-- Name: idempotency_keys_2025_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2025_10_pkey;


--
-- Name: idempotency_keys_2025_10_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2025_10_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2025_11_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2025_11_expires_at_idx;


--
-- Name: idempotency_keys_2025_11_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2025_11_expires_at_idx1;


--
-- Name: idempotency_keys_2025_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2025_11_pkey;


--
-- Name: idempotency_keys_2025_11_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2025_11_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2025_12_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2025_12_expires_at_idx;


--
-- Name: idempotency_keys_2025_12_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2025_12_expires_at_idx1;


--
-- Name: idempotency_keys_2025_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2025_12_pkey;


--
-- Name: idempotency_keys_2025_12_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2025_12_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_01_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_01_expires_at_idx;


--
-- Name: idempotency_keys_2026_01_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_01_expires_at_idx1;


--
-- Name: idempotency_keys_2026_01_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_01_pkey;


--
-- Name: idempotency_keys_2026_01_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_01_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_02_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_02_expires_at_idx;


--
-- Name: idempotency_keys_2026_02_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_02_expires_at_idx1;


--
-- Name: idempotency_keys_2026_02_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_02_pkey;


--
-- Name: idempotency_keys_2026_02_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_02_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_03_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_03_expires_at_idx;


--
-- Name: idempotency_keys_2026_03_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_03_expires_at_idx1;


--
-- Name: idempotency_keys_2026_03_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_03_pkey;


--
-- Name: idempotency_keys_2026_03_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_03_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_04_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_04_expires_at_idx;


--
-- Name: idempotency_keys_2026_04_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_04_expires_at_idx1;


--
-- Name: idempotency_keys_2026_04_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_04_pkey;


--
-- Name: idempotency_keys_2026_04_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_04_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_05_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_05_expires_at_idx;


--
-- Name: idempotency_keys_2026_05_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_05_expires_at_idx1;


--
-- Name: idempotency_keys_2026_05_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_05_pkey;


--
-- Name: idempotency_keys_2026_05_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_05_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_06_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_06_expires_at_idx;


--
-- Name: idempotency_keys_2026_06_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_06_expires_at_idx1;


--
-- Name: idempotency_keys_2026_06_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_06_pkey;


--
-- Name: idempotency_keys_2026_06_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_06_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_07_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_07_expires_at_idx;


--
-- Name: idempotency_keys_2026_07_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_07_expires_at_idx1;


--
-- Name: idempotency_keys_2026_07_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_07_pkey;


--
-- Name: idempotency_keys_2026_07_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_07_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_08_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_08_expires_at_idx;


--
-- Name: idempotency_keys_2026_08_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_08_expires_at_idx1;


--
-- Name: idempotency_keys_2026_08_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_08_pkey;


--
-- Name: idempotency_keys_2026_08_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_08_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_09_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_09_expires_at_idx;


--
-- Name: idempotency_keys_2026_09_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_09_expires_at_idx1;


--
-- Name: idempotency_keys_2026_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_09_pkey;


--
-- Name: idempotency_keys_2026_09_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_09_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_10_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_10_expires_at_idx;


--
-- Name: idempotency_keys_2026_10_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_10_expires_at_idx1;


--
-- Name: idempotency_keys_2026_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_10_pkey;


--
-- Name: idempotency_keys_2026_10_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_10_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_11_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_11_expires_at_idx;


--
-- Name: idempotency_keys_2026_11_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_11_expires_at_idx1;


--
-- Name: idempotency_keys_2026_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_11_pkey;


--
-- Name: idempotency_keys_2026_11_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_11_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_2026_12_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_2026_12_expires_at_idx;


--
-- Name: idempotency_keys_2026_12_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_2026_12_expires_at_idx1;


--
-- Name: idempotency_keys_2026_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_2026_12_pkey;


--
-- Name: idempotency_keys_2026_12_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_2026_12_tenant_id_idempotency_key_expires__key;


--
-- Name: idempotency_keys_default_expires_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_idempotency_expiry ATTACH PARTITION public.idempotency_keys_default_expires_at_idx;


--
-- Name: idempotency_keys_default_expires_at_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_idempotency_expires_at ATTACH PARTITION public.idempotency_keys_default_expires_at_idx1;


--
-- Name: idempotency_keys_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idempotency_keys_pkey ATTACH PARTITION public.idempotency_keys_default_pkey;


--
-- Name: idempotency_keys_default_tenant_id_idempotency_key_expires__key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.uq_idempotency_key ATTACH PARTITION public.idempotency_keys_default_tenant_id_idempotency_key_expires__key;


--
-- Name: outbox_events_2025_09_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2025_09_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2025_09_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2025_09_available_at_idx;


--
-- Name: outbox_events_2025_09_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2025_09_correlation_id_idx;


--
-- Name: outbox_events_2025_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2025_09_pkey;


--
-- Name: outbox_events_2025_09_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2025_09_status_available_at_created_at_idx;


--
-- Name: outbox_events_2025_10_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2025_10_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2025_10_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2025_10_available_at_idx;


--
-- Name: outbox_events_2025_10_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2025_10_correlation_id_idx;


--
-- Name: outbox_events_2025_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2025_10_pkey;


--
-- Name: outbox_events_2025_10_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2025_10_status_available_at_created_at_idx;


--
-- Name: outbox_events_2025_11_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2025_11_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2025_11_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2025_11_available_at_idx;


--
-- Name: outbox_events_2025_11_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2025_11_correlation_id_idx;


--
-- Name: outbox_events_2025_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2025_11_pkey;


--
-- Name: outbox_events_2025_11_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2025_11_status_available_at_created_at_idx;


--
-- Name: outbox_events_2025_12_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2025_12_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2025_12_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2025_12_available_at_idx;


--
-- Name: outbox_events_2025_12_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2025_12_correlation_id_idx;


--
-- Name: outbox_events_2025_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2025_12_pkey;


--
-- Name: outbox_events_2025_12_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2025_12_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_01_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_01_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_01_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_01_available_at_idx;


--
-- Name: outbox_events_2026_01_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_01_correlation_id_idx;


--
-- Name: outbox_events_2026_01_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_01_pkey;


--
-- Name: outbox_events_2026_01_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_01_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_02_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_02_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_02_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_02_available_at_idx;


--
-- Name: outbox_events_2026_02_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_02_correlation_id_idx;


--
-- Name: outbox_events_2026_02_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_02_pkey;


--
-- Name: outbox_events_2026_02_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_02_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_03_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_03_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_03_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_03_available_at_idx;


--
-- Name: outbox_events_2026_03_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_03_correlation_id_idx;


--
-- Name: outbox_events_2026_03_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_03_pkey;


--
-- Name: outbox_events_2026_03_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_03_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_04_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_04_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_04_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_04_available_at_idx;


--
-- Name: outbox_events_2026_04_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_04_correlation_id_idx;


--
-- Name: outbox_events_2026_04_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_04_pkey;


--
-- Name: outbox_events_2026_04_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_04_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_05_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_05_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_05_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_05_available_at_idx;


--
-- Name: outbox_events_2026_05_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_05_correlation_id_idx;


--
-- Name: outbox_events_2026_05_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_05_pkey;


--
-- Name: outbox_events_2026_05_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_05_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_06_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_06_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_06_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_06_available_at_idx;


--
-- Name: outbox_events_2026_06_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_06_correlation_id_idx;


--
-- Name: outbox_events_2026_06_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_06_pkey;


--
-- Name: outbox_events_2026_06_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_06_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_07_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_07_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_07_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_07_available_at_idx;


--
-- Name: outbox_events_2026_07_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_07_correlation_id_idx;


--
-- Name: outbox_events_2026_07_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_07_pkey;


--
-- Name: outbox_events_2026_07_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_07_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_08_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_08_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_08_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_08_available_at_idx;


--
-- Name: outbox_events_2026_08_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_08_correlation_id_idx;


--
-- Name: outbox_events_2026_08_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_08_pkey;


--
-- Name: outbox_events_2026_08_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_08_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_09_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_09_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_09_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_09_available_at_idx;


--
-- Name: outbox_events_2026_09_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_09_correlation_id_idx;


--
-- Name: outbox_events_2026_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_09_pkey;


--
-- Name: outbox_events_2026_09_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_09_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_10_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_10_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_10_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_10_available_at_idx;


--
-- Name: outbox_events_2026_10_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_10_correlation_id_idx;


--
-- Name: outbox_events_2026_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_10_pkey;


--
-- Name: outbox_events_2026_10_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_10_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_11_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_11_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_11_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_11_available_at_idx;


--
-- Name: outbox_events_2026_11_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_11_correlation_id_idx;


--
-- Name: outbox_events_2026_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_11_pkey;


--
-- Name: outbox_events_2026_11_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_11_status_available_at_created_at_idx;


--
-- Name: outbox_events_2026_12_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_2026_12_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_2026_12_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_2026_12_available_at_idx;


--
-- Name: outbox_events_2026_12_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_2026_12_correlation_id_idx;


--
-- Name: outbox_events_2026_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_2026_12_pkey;


--
-- Name: outbox_events_2026_12_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_2026_12_status_available_at_created_at_idx;


--
-- Name: outbox_events_default_aggregate_type_aggregate_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_aggregate ATTACH PARTITION public.outbox_events_default_aggregate_type_aggregate_id_idx;


--
-- Name: outbox_events_default_available_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.brin_outbox_events_available_at ATTACH PARTITION public.outbox_events_default_available_at_idx;


--
-- Name: outbox_events_default_correlation_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_correlation ATTACH PARTITION public.outbox_events_default_correlation_id_idx;


--
-- Name: outbox_events_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.outbox_events_pkey ATTACH PARTITION public.outbox_events_default_pkey;


--
-- Name: outbox_events_default_status_available_at_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_outbox_pending ATTACH PARTITION public.outbox_events_default_status_available_at_created_at_idx;


--
-- Name: admin_mfa_methods trg_admin_mfa_methods_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_admin_mfa_methods_updated_at BEFORE UPDATE ON public.admin_mfa_methods FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_roles trg_admin_roles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_admin_roles_updated_at BEFORE UPDATE ON public.admin_roles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_users trg_admin_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_admin_users_updated_at BEFORE UPDATE ON public.admin_users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_revenue_settlement_configurations trg_capture_revenue_settlement_config_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_capture_revenue_settlement_config_history AFTER INSERT OR UPDATE ON public.tenant_revenue_settlement_configurations FOR EACH ROW EXECUTE FUNCTION public.capture_revenue_settlement_config_history();


--
-- Name: tenant_revenue_share_rules trg_capture_revenue_share_rule_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_capture_revenue_share_rule_history AFTER INSERT OR UPDATE ON public.tenant_revenue_share_rules FOR EACH ROW EXECUTE FUNCTION public.capture_revenue_share_rule_history();


--
-- Name: tenant_commercial_agreements trg_commercial_agreements_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_commercial_agreements_updated_at BEFORE UPDATE ON public.tenant_commercial_agreements FOR EACH ROW EXECUTE FUNCTION public.set_revenue_config_updated_at();


--
-- Name: feature_modules trg_feature_modules_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_feature_modules_updated_at BEFORE UPDATE ON public.feature_modules FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: feature_usage_limits trg_feature_usage_limits_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_feature_usage_limits_updated_at BEFORE UPDATE ON public.feature_usage_limits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: features trg_features_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_features_updated_at BEFORE UPDATE ON public.features FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: idempotency_keys trg_idempotency_keys_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_idempotency_keys_updated_at BEFORE UPDATE ON public.idempotency_keys FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: operation_requests trg_operation_binding_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_operation_binding_immutable BEFORE UPDATE ON public.operation_requests FOR EACH ROW EXECUTE FUNCTION public.enforce_operation_binding_immutability();


--
-- Name: operation_approvals trg_operation_maker_checker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_operation_maker_checker BEFORE INSERT OR UPDATE ON public.operation_approvals FOR EACH ROW EXECUTE FUNCTION public.enforce_maker_checker();


--
-- Name: operation_requests trg_operation_requests_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_operation_requests_updated_at BEFORE UPDATE ON public.operation_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_revenue_share_rules trg_protect_active_revenue_share_terms; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_protect_active_revenue_share_terms BEFORE UPDATE ON public.tenant_revenue_share_rules FOR EACH ROW EXECUTE FUNCTION public.protect_active_revenue_share_terms();


--
-- Name: provider_capability_availability_history trg_protect_provider_capability_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_protect_provider_capability_history BEFORE DELETE OR UPDATE ON public.provider_capability_availability_history FOR EACH ROW EXECUTE FUNCTION public.protect_provider_capability_history();


--
-- Name: tenant_provider_selection_history trg_protect_provider_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_protect_provider_history BEFORE DELETE OR UPDATE ON public.tenant_provider_selection_history FOR EACH ROW EXECUTE FUNCTION public.protect_provider_history();


--
-- Name: configuration_versions trg_protect_published_configuration; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_protect_published_configuration BEFORE DELETE OR UPDATE ON public.configuration_versions FOR EACH ROW EXECUTE FUNCTION public.protect_published_configuration();


--
-- Name: reconciliation_exceptions trg_reconciliation_exceptions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_reconciliation_exceptions_updated_at BEFORE UPDATE ON public.reconciliation_exceptions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: reconciliation_jobs trg_reconciliation_jobs_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_reconciliation_jobs_updated_at BEFORE UPDATE ON public.reconciliation_jobs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_revenue_settlement_configurations trg_revenue_settlement_config_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_revenue_settlement_config_updated_at BEFORE UPDATE ON public.tenant_revenue_settlement_configurations FOR EACH ROW EXECUTE FUNCTION public.set_revenue_config_updated_at();


--
-- Name: tenant_revenue_share_rules trg_revenue_share_rules_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_revenue_share_rules_updated_at BEFORE UPDATE ON public.tenant_revenue_share_rules FOR EACH ROW EXECUTE FUNCTION public.set_revenue_config_updated_at();


--
-- Name: tenant_revenue_share_tiers trg_revenue_share_tiers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_revenue_share_tiers_updated_at BEFORE UPDATE ON public.tenant_revenue_share_tiers FOR EACH ROW EXECUTE FUNCTION public.set_revenue_config_updated_at();


--
-- Name: support_categories trg_support_categories_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_support_categories_updated_at BEFORE UPDATE ON public.support_categories FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: support_tickets trg_support_tickets_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_support_tickets_updated_at BEFORE UPDATE ON public.support_tickets FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: system_configurations trg_system_configurations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_system_configurations_updated_at BEFORE UPDATE ON public.system_configurations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_api_credentials trg_tenant_api_credentials_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_api_credentials_updated_at BEFORE UPDATE ON public.tenant_api_credentials FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_configurations trg_tenant_configurations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_configurations_updated_at BEFORE UPDATE ON public.tenant_configurations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_domains trg_tenant_domains_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_domains_updated_at BEFORE UPDATE ON public.tenant_domains FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_feature_overrides trg_tenant_feature_overrides_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_feature_overrides_updated_at BEFORE UPDATE ON public.tenant_feature_overrides FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_feature_usage trg_tenant_feature_usage_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_feature_usage_updated_at BEFORE UPDATE ON public.tenant_feature_usage FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_profiles trg_tenant_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_profiles_updated_at BEFORE UPDATE ON public.tenant_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_service_configurations trg_tenant_service_configurations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_service_configurations_updated_at BEFORE UPDATE ON public.tenant_service_configurations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_settings trg_tenant_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_settings_updated_at BEFORE UPDATE ON public.tenant_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_tiers trg_tenant_tiers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_tiers_updated_at BEFORE UPDATE ON public.tenant_tiers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenant_webhooks trg_tenant_webhooks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenant_webhooks_updated_at BEFORE UPDATE ON public.tenant_webhooks FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tenants trg_tenants_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tenants_updated_at BEFORE UPDATE ON public.tenants FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: tier_features trg_tier_features_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tier_features_updated_at BEFORE UPDATE ON public.tier_features FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: configuration_versions trg_validate_configuration_publication; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validate_configuration_publication BEFORE INSERT OR UPDATE ON public.configuration_versions FOR EACH ROW EXECUTE FUNCTION public.validate_configuration_publication();


--
-- Name: tenant_provider_selections trg_validate_provider_selection; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validate_provider_selection BEFORE INSERT OR UPDATE ON public.tenant_provider_selections FOR EACH ROW EXECUTE FUNCTION public.validate_provider_selection();


--
-- Name: tenant_revenue_share_rules trg_validate_revenue_rule_agreement_tenant; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validate_revenue_rule_agreement_tenant BEFORE INSERT OR UPDATE ON public.tenant_revenue_share_rules FOR EACH ROW EXECUTE FUNCTION public.validate_revenue_rule_agreement_tenant();


--
-- Name: tenant_revenue_share_tiers trg_validate_revenue_share_tier_tenant; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validate_revenue_share_tier_tenant BEFORE INSERT OR UPDATE ON public.tenant_revenue_share_tiers FOR EACH ROW EXECUTE FUNCTION public.validate_revenue_share_tier_tenant();


--
-- Name: tenant_revenue_settlement_configurations trg_validate_settlement_config_agreement_tenant; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validate_settlement_config_agreement_tenant BEFORE INSERT OR UPDATE ON public.tenant_revenue_settlement_configurations FOR EACH ROW EXECUTE FUNCTION public.validate_settlement_config_agreement_tenant();


--
-- Name: configuration_versions configuration_versions_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.operation_requests(id);


--
-- Name: configuration_versions configuration_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admin_users(id);


--
-- Name: configuration_versions configuration_versions_definition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_definition_id_fkey FOREIGN KEY (definition_id) REFERENCES public.configuration_definitions(id);


--
-- Name: configuration_versions configuration_versions_published_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_published_by_fkey FOREIGN KEY (published_by) REFERENCES public.admin_users(id);


--
-- Name: configuration_versions configuration_versions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: configuration_versions configuration_versions_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration_versions
    ADD CONSTRAINT configuration_versions_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tenant_tiers(id);


--
-- Name: admin_mfa_methods fk_admin_mfa_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_mfa_methods
    ADD CONSTRAINT fk_admin_mfa_user FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id) ON DELETE CASCADE;


--
-- Name: admin_sessions fk_admin_session_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT fk_admin_session_user FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id) ON DELETE CASCADE;


--
-- Name: features fk_feature_module; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT fk_feature_module FOREIGN KEY (module_id) REFERENCES public.feature_modules(id);


--
-- Name: operation_actions fk_operation_action_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_actions
    ADD CONSTRAINT fk_operation_action_request FOREIGN KEY (operation_request_id) REFERENCES public.operation_requests(id) ON DELETE CASCADE;


--
-- Name: operation_approvals fk_operation_approval_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_approvals
    ADD CONSTRAINT fk_operation_approval_request FOREIGN KEY (operation_request_id) REFERENCES public.operation_requests(id) ON DELETE CASCADE;


--
-- Name: operation_attachments fk_operation_attachment_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_attachments
    ADD CONSTRAINT fk_operation_attachment_request FOREIGN KEY (operation_request_id) REFERENCES public.operation_requests(id) ON DELETE CASCADE;


--
-- Name: operation_comments fk_operation_comment_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_comments
    ADD CONSTRAINT fk_operation_comment_request FOREIGN KEY (operation_request_id) REFERENCES public.operation_requests(id) ON DELETE CASCADE;


--
-- Name: outbox_event_attempts fk_outbox_attempt_event; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_event_attempts
    ADD CONSTRAINT fk_outbox_attempt_event FOREIGN KEY (outbox_event_id, outbox_event_created_at) REFERENCES public.outbox_events(id, created_at) ON DELETE CASCADE;


--
-- Name: tenant_feature_overrides fk_override_feature; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_feature_overrides
    ADD CONSTRAINT fk_override_feature FOREIGN KEY (feature_id) REFERENCES public.features(id);


--
-- Name: reconciliation_actions fk_reconciliation_action_exception; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_actions
    ADD CONSTRAINT fk_reconciliation_action_exception FOREIGN KEY (reconciliation_exception_id) REFERENCES public.reconciliation_exceptions(id) ON DELETE CASCADE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exception_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exception_item FOREIGN KEY (reconciliation_item_id) REFERENCES public.reconciliation_items(id) ON DELETE CASCADE;


--
-- Name: reconciliation_items fk_reconciliation_item_run; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_item_run FOREIGN KEY (reconciliation_run_id) REFERENCES public.reconciliation_runs(id) ON DELETE CASCADE;


--
-- Name: reconciliation_runs fk_reconciliation_run_job; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_run_job FOREIGN KEY (reconciliation_job_id) REFERENCES public.reconciliation_jobs(id);


--
-- Name: admin_role_permissions fk_role_permission_permission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions
    ADD CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES public.admin_permissions(id) ON DELETE CASCADE;


--
-- Name: admin_role_permissions fk_role_permission_role; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions
    ADD CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES public.admin_roles(id) ON DELETE CASCADE;


--
-- Name: tenant_api_credentials fk_tenant_api_credentials_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_api_credentials
    ADD CONSTRAINT fk_tenant_api_credentials_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_configurations fk_tenant_configurations_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_configurations
    ADD CONSTRAINT fk_tenant_configurations_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_domains fk_tenant_domains_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_domains
    ADD CONSTRAINT fk_tenant_domains_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_profiles fk_tenant_profiles_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_profiles
    ADD CONSTRAINT fk_tenant_profiles_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_service_configurations fk_tenant_service_configurations_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_service_configurations
    ADD CONSTRAINT fk_tenant_service_configurations_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_settings fk_tenant_settings_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT fk_tenant_settings_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenant_status_history fk_tenant_status_history_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_status_history
    ADD CONSTRAINT fk_tenant_status_history_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenants fk_tenant_tier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT fk_tenant_tier FOREIGN KEY (tier_id) REFERENCES public.tenant_tiers(id);


--
-- Name: tenant_webhooks fk_tenant_webhooks_tenant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_webhooks
    ADD CONSTRAINT fk_tenant_webhooks_tenant FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: support_ticket_assignments fk_ticket_assignment_ticket; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_assignments
    ADD CONSTRAINT fk_ticket_assignment_ticket FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- Name: support_ticket_events fk_ticket_event_ticket; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_events
    ADD CONSTRAINT fk_ticket_event_ticket FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- Name: support_ticket_messages fk_ticket_message_ticket; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_ticket_messages
    ADD CONSTRAINT fk_ticket_message_ticket FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- Name: tier_features fk_tier_feature_feature; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tier_features
    ADD CONSTRAINT fk_tier_feature_feature FOREIGN KEY (feature_id) REFERENCES public.features(id);


--
-- Name: tier_features fk_tier_feature_tier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tier_features
    ADD CONSTRAINT fk_tier_feature_tier FOREIGN KEY (tier_id) REFERENCES public.tenant_tiers(id);


--
-- Name: tenant_feature_usage fk_usage_feature; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_feature_usage
    ADD CONSTRAINT fk_usage_feature FOREIGN KEY (feature_id) REFERENCES public.features(id);


--
-- Name: feature_usage_limits fk_usage_limit_feature; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_usage_limits
    ADD CONSTRAINT fk_usage_limit_feature FOREIGN KEY (feature_id) REFERENCES public.features(id);


--
-- Name: admin_user_roles fk_user_role_role; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES public.admin_roles(id) ON DELETE CASCADE;


--
-- Name: admin_user_roles fk_user_role_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT fk_user_role_user FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id) ON DELETE CASCADE;


--
-- Name: provider_capabilities provider_capabilities_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capabilities
    ADD CONSTRAINT provider_capabilities_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.provider_catalog(provider_code);


--
-- Name: provider_capabilities provider_capabilities_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capabilities
    ADD CONSTRAINT provider_capabilities_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.admin_users(id);


--
-- Name: provider_capability_availability_history provider_capability_availability_hi_provider_capability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capability_availability_history
    ADD CONSTRAINT provider_capability_availability_hi_provider_capability_id_fkey FOREIGN KEY (provider_capability_id) REFERENCES public.provider_capabilities(id);


--
-- Name: provider_capability_availability_history provider_capability_availability_history_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capability_availability_history
    ADD CONSTRAINT provider_capability_availability_history_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.operation_requests(id);


--
-- Name: provider_capability_availability_history provider_capability_availability_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_capability_availability_history
    ADD CONSTRAINT provider_capability_availability_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.admin_users(id);


--
-- Name: tenant_configuration_publications tenant_configuration_publications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_configuration_publications
    ADD CONSTRAINT tenant_configuration_publications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.operation_requests(id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_selected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_selected_by_fkey FOREIGN KEY (selected_by) REFERENCES public.admin_users(id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_selection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_selection_id_fkey FOREIGN KEY (selection_id) REFERENCES public.tenant_provider_selections(id);


--
-- Name: tenant_provider_selection_history tenant_provider_selection_history_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selection_history
    ADD CONSTRAINT tenant_provider_selection_history_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_provider_selections tenant_provider_selections_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.operation_requests(id);


--
-- Name: tenant_provider_selections tenant_provider_selections_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.provider_catalog(provider_code);


--
-- Name: tenant_provider_selections tenant_provider_selections_selected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_selected_by_fkey FOREIGN KEY (selected_by) REFERENCES public.admin_users(id);


--
-- Name: tenant_provider_selections tenant_provider_selections_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_provider_selections
    ADD CONSTRAINT tenant_provider_selections_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_revenue_settlement_configuration_history tenant_revenue_settlement_conf_settlement_configuration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configuration_history
    ADD CONSTRAINT tenant_revenue_settlement_conf_settlement_configuration_id_fkey FOREIGN KEY (settlement_configuration_id) REFERENCES public.tenant_revenue_settlement_configurations(id) ON DELETE RESTRICT;


--
-- Name: tenant_revenue_settlement_configurations tenant_revenue_settlement_configurations_agreement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_settlement_configurations
    ADD CONSTRAINT tenant_revenue_settlement_configurations_agreement_id_fkey FOREIGN KEY (agreement_id) REFERENCES public.tenant_commercial_agreements(id) ON DELETE RESTRICT;


--
-- Name: tenant_revenue_share_rule_history tenant_revenue_share_rule_history_revenue_share_rule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rule_history
    ADD CONSTRAINT tenant_revenue_share_rule_history_revenue_share_rule_id_fkey FOREIGN KEY (revenue_share_rule_id) REFERENCES public.tenant_revenue_share_rules(id) ON DELETE RESTRICT;


--
-- Name: tenant_revenue_share_rules tenant_revenue_share_rules_agreement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_rules
    ADD CONSTRAINT tenant_revenue_share_rules_agreement_id_fkey FOREIGN KEY (agreement_id) REFERENCES public.tenant_commercial_agreements(id) ON DELETE RESTRICT;


--
-- Name: tenant_revenue_share_tiers tenant_revenue_share_tiers_revenue_share_rule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_revenue_share_tiers
    ADD CONSTRAINT tenant_revenue_share_tiers_revenue_share_rule_id_fkey FOREIGN KEY (revenue_share_rule_id) REFERENCES public.tenant_revenue_share_rules(id) ON DELETE RESTRICT;


--
-- Name: admin_activity_logs admin_activity_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_activity_isolation ON public.admin_activity_logs USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: admin_activity_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_activity_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_login_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_login_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_login_attempts admin_login_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_login_isolation ON public.admin_login_attempts USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.admin_users u
  WHERE ((u.id = admin_login_attempts.admin_user_id) AND (u.tenant_id = public.current_tenant_id()))))));


--
-- Name: admin_mfa_methods admin_mfa_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_mfa_isolation ON public.admin_mfa_methods USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.admin_users u
  WHERE ((u.id = admin_mfa_methods.admin_user_id) AND (u.tenant_id = public.current_tenant_id()))))));


--
-- Name: admin_mfa_methods; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_mfa_methods ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_roles admin_role_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_role_isolation ON public.admin_roles USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: admin_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_sessions admin_session_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_session_isolation ON public.admin_sessions USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.admin_users u
  WHERE ((u.id = admin_sessions.admin_user_id) AND (u.tenant_id = public.current_tenant_id()))))));


--
-- Name: admin_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_users admin_user_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_user_isolation ON public.admin_users USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: admin_user_roles admin_user_role_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_user_role_isolation ON public.admin_user_roles USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.admin_users u
  WHERE ((u.id = admin_user_roles.admin_user_id) AND ((u.tenant_id = public.current_tenant_id()) OR public.is_platform_admin()))))));


--
-- Name: admin_user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs audit_log_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_log_isolation ON public.audit_logs USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: configuration_audit_logs configuration_audit_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY configuration_audit_isolation ON public.configuration_audit_logs USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: configuration_audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.configuration_audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_configuration_publications configuration_publication_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY configuration_publication_isolation ON public.tenant_configuration_publications USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: configuration_versions configuration_version_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY configuration_version_isolation ON public.configuration_versions USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: configuration_versions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.configuration_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: data_access_logs data_access_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY data_access_isolation ON public.data_access_logs USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: data_access_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.data_access_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_feature_usage feature_usage_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feature_usage_isolation ON public.tenant_feature_usage USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: feature_usage_limits feature_usage_limit_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feature_usage_limit_isolation ON public.feature_usage_limits USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: feature_usage_limits; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feature_usage_limits ENABLE ROW LEVEL SECURITY;

--
-- Name: idempotency_keys idempotency_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY idempotency_isolation ON public.idempotency_keys USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: idempotency_keys; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.idempotency_keys ENABLE ROW LEVEL SECURITY;

--
-- Name: inbox_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inbox_events ENABLE ROW LEVEL SECURITY;

--
-- Name: inbox_events inbox_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY inbox_isolation ON public.inbox_events USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: operation_actions operation_action_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY operation_action_isolation ON public.operation_actions USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.operation_requests r
  WHERE ((r.id = operation_actions.operation_request_id) AND (r.tenant_id = public.current_tenant_id()))))));


--
-- Name: operation_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_approvals operation_approval_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY operation_approval_isolation ON public.operation_approvals USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.operation_requests r
  WHERE ((r.id = operation_approvals.operation_request_id) AND (r.tenant_id = public.current_tenant_id()))))));


--
-- Name: operation_approvals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_approvals ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_attachments operation_attachment_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY operation_attachment_isolation ON public.operation_attachments USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.operation_requests r
  WHERE ((r.id = operation_attachments.operation_request_id) AND (r.tenant_id = public.current_tenant_id()))))));


--
-- Name: operation_attachments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_attachments ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_comments operation_comment_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY operation_comment_isolation ON public.operation_comments USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.operation_requests r
  WHERE ((r.id = operation_comments.operation_request_id) AND (r.tenant_id = public.current_tenant_id()))))));


--
-- Name: operation_comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_requests operation_request_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY operation_request_isolation ON public.operation_requests USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: operation_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_event_attempts outbox_attempt_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY outbox_attempt_isolation ON public.outbox_event_attempts USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.outbox_events e
  WHERE ((e.id = outbox_event_attempts.outbox_event_id) AND (e.created_at = outbox_event_attempts.outbox_event_created_at) AND ((e.tenant_id IS NULL) OR (e.tenant_id = public.current_tenant_id())))))));


--
-- Name: outbox_event_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outbox_event_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outbox_events ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_events outbox_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY outbox_isolation ON public.outbox_events USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: provider_capability_availability_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.provider_capability_availability_history ENABLE ROW LEVEL SECURITY;

--
-- Name: provider_capability_availability_history provider_capability_history_platform_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY provider_capability_history_platform_only ON public.provider_capability_availability_history USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());


--
-- Name: reconciliation_actions reconciliation_action_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_action_isolation ON public.reconciliation_actions USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.reconciliation_exceptions e
  WHERE ((e.id = reconciliation_actions.reconciliation_exception_id) AND ((e.tenant_id IS NULL) OR (e.tenant_id = public.current_tenant_id())))))));


--
-- Name: reconciliation_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reconciliation_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: reconciliation_exceptions reconciliation_exception_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_exception_isolation ON public.reconciliation_exceptions USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: reconciliation_exceptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reconciliation_exceptions ENABLE ROW LEVEL SECURITY;

--
-- Name: reconciliation_items reconciliation_item_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_item_isolation ON public.reconciliation_items USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: reconciliation_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reconciliation_items ENABLE ROW LEVEL SECURITY;

--
-- Name: reconciliation_jobs reconciliation_job_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_job_isolation ON public.reconciliation_jobs USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: reconciliation_jobs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reconciliation_jobs ENABLE ROW LEVEL SECURITY;

--
-- Name: reconciliation_runs reconciliation_run_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_run_isolation ON public.reconciliation_runs USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.reconciliation_jobs j
  WHERE ((j.id = reconciliation_runs.reconciliation_job_id) AND ((j.tenant_id IS NULL) OR (j.tenant_id = public.current_tenant_id())))))));


--
-- Name: reconciliation_runs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reconciliation_runs ENABLE ROW LEVEL SECURITY;

--
-- Name: security_events security_event_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY security_event_isolation ON public.security_events USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: security_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;

--
-- Name: support_ticket_assignments support_assignment_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY support_assignment_isolation ON public.support_ticket_assignments USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_ticket_assignments.ticket_id) AND (t.tenant_id = public.current_tenant_id()))))));


--
-- Name: support_categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.support_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: support_categories support_category_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY support_category_isolation ON public.support_categories USING ((public.is_platform_admin() OR (tenant_id IS NULL) OR (tenant_id = public.current_tenant_id())));


--
-- Name: support_ticket_events support_event_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY support_event_isolation ON public.support_ticket_events USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_ticket_events.ticket_id) AND (t.tenant_id = public.current_tenant_id()))))));


--
-- Name: support_ticket_messages support_message_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY support_message_isolation ON public.support_ticket_messages USING ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_ticket_messages.ticket_id) AND (t.tenant_id = public.current_tenant_id()))))));


--
-- Name: support_ticket_assignments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.support_ticket_assignments ENABLE ROW LEVEL SECURITY;

--
-- Name: support_ticket_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.support_ticket_events ENABLE ROW LEVEL SECURITY;

--
-- Name: support_tickets support_ticket_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY support_ticket_isolation ON public.support_tickets USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: support_ticket_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.support_ticket_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: support_tickets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_api_credentials; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_api_credentials ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_api_credentials tenant_api_credentials_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_api_credentials_isolation ON public.tenant_api_credentials USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_commercial_agreements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_commercial_agreements ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_commercial_agreements tenant_commercial_agreements_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_commercial_agreements_rls ON public.tenant_commercial_agreements USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_configurations tenant_configuration_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_configuration_isolation ON public.tenant_configurations USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_configuration_publications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_configuration_publications ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_configurations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_domains; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_domains tenant_domains_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_domains_isolation ON public.tenant_domains USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_feature_overrides tenant_feature_override_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_feature_override_isolation ON public.tenant_feature_overrides USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_feature_overrides; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_feature_overrides ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_feature_usage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_feature_usage ENABLE ROW LEVEL SECURITY;

--
-- Name: tenants tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.tenants USING ((public.is_platform_admin() OR (id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (id = public.current_tenant_id())));


--
-- Name: tenant_profiles tenant_profile_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_profile_isolation ON public.tenant_profiles USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_provider_selection_history tenant_provider_history_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_provider_history_isolation ON public.tenant_provider_selection_history USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_provider_selection_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_provider_selection_history ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_provider_selections tenant_provider_selection_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_provider_selection_isolation ON public.tenant_provider_selections USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_provider_selections; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_provider_selections ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_settlement_configuration_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_revenue_settlement_configuration_history ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_settlement_configuration_history tenant_revenue_settlement_configuration_history_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_revenue_settlement_configuration_history_rls ON public.tenant_revenue_settlement_configuration_history USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_revenue_settlement_configurations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_revenue_settlement_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_settlement_configurations tenant_revenue_settlement_configurations_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_revenue_settlement_configurations_rls ON public.tenant_revenue_settlement_configurations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_revenue_share_rule_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_revenue_share_rule_history ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_share_rule_history tenant_revenue_share_rule_history_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_revenue_share_rule_history_rls ON public.tenant_revenue_share_rule_history USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_revenue_share_rules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_revenue_share_rules ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_share_rules tenant_revenue_share_rules_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_revenue_share_rules_rls ON public.tenant_revenue_share_rules USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_revenue_share_tiers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_revenue_share_tiers ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_revenue_share_tiers tenant_revenue_share_tiers_rls; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_revenue_share_tiers_rls ON public.tenant_revenue_share_tiers USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_service_configurations tenant_service_configuration_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_service_configuration_isolation ON public.tenant_service_configurations USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_service_configurations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_service_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_settings tenant_settings_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_settings_isolation ON public.tenant_settings USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_status_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_status_history ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_status_history tenant_status_history_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_status_history_isolation ON public.tenant_status_history USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenant_webhooks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_webhooks ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_webhooks tenant_webhooks_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_webhooks_isolation ON public.tenant_webhooks USING ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id()))) WITH CHECK ((public.is_platform_admin() OR (tenant_id = public.current_tenant_id())));


--
-- Name: tenants; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

--
-- Name: tier_features; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tier_features ENABLE ROW LEVEL SECURITY;

--
-- Name: tier_features tier_features_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tier_features_read ON public.tier_features USING (true);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO parc_service;
GRANT USAGE ON SCHEMA public TO parc_readonly;
GRANT USAGE ON SCHEMA public TO parc_admin;
GRANT USAGE ON SCHEMA public TO parc_tenant_admin_runtime;
GRANT USAGE ON SCHEMA public TO parc_tenant_admin_platform;
GRANT USAGE ON SCHEMA public TO parc_tenant_admin_worker;
GRANT USAGE ON SCHEMA public TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_activity_logs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_activity_logs TO parc_service;
GRANT SELECT ON TABLE public.admin_activity_logs TO parc_readonly;
GRANT ALL ON TABLE public.admin_activity_logs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_activity_logs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_activity_logs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_activity_logs TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_login_attempts; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_login_attempts TO parc_service;
GRANT SELECT ON TABLE public.admin_login_attempts TO parc_readonly;
GRANT ALL ON TABLE public.admin_login_attempts TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_login_attempts TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_login_attempts TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_login_attempts TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_mfa_methods; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_mfa_methods TO parc_service;
GRANT SELECT ON TABLE public.admin_mfa_methods TO parc_readonly;
GRANT ALL ON TABLE public.admin_mfa_methods TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_mfa_methods TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_mfa_methods TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_mfa_methods TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_permissions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_permissions TO parc_service;
GRANT SELECT ON TABLE public.admin_permissions TO parc_readonly;
GRANT ALL ON TABLE public.admin_permissions TO parc_admin;
GRANT SELECT ON TABLE public.admin_permissions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_permissions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_permissions TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_role_permissions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_role_permissions TO parc_service;
GRANT SELECT ON TABLE public.admin_role_permissions TO parc_readonly;
GRANT ALL ON TABLE public.admin_role_permissions TO parc_admin;
GRANT SELECT ON TABLE public.admin_role_permissions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_role_permissions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_role_permissions TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_roles; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_roles TO parc_service;
GRANT SELECT ON TABLE public.admin_roles TO parc_readonly;
GRANT ALL ON TABLE public.admin_roles TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_roles TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_roles TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_roles TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_sessions TO parc_service;
GRANT SELECT ON TABLE public.admin_sessions TO parc_readonly;
GRANT ALL ON TABLE public.admin_sessions TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_sessions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_sessions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_sessions TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_user_roles; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_user_roles TO parc_service;
GRANT SELECT ON TABLE public.admin_user_roles TO parc_readonly;
GRANT ALL ON TABLE public.admin_user_roles TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_user_roles TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_user_roles TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_user_roles TO parc_tenant_admin_readonly;


--
-- Name: TABLE admin_users; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_users TO parc_service;
GRANT SELECT ON TABLE public.admin_users TO parc_readonly;
GRANT ALL ON TABLE public.admin_users TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_users TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.admin_users TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.admin_users TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs TO parc_service;
GRANT SELECT ON TABLE public.audit_logs TO parc_readonly;
GRANT ALL ON TABLE public.audit_logs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2025_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_09 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2025_09 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2025_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2025_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2025_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_10 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2025_10 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2025_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2025_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2025_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_11 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2025_11 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2025_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2025_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2025_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_12 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2025_12 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2025_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2025_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2025_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_01; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_01 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_01 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_01 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_01 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_01 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_02; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_02 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_02 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_02 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_02 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_02 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_03; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_03 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_03 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_03 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_03 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_03 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_04; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_04 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_04 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_04 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_04 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_04 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_05; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_05 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_05 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_05 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_05 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_05 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_06; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_06 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_06 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_06 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_06 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_06 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_07; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_07 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_07 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_07 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_07 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_07 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_08; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_08 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_08 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_08 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_08 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_08 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_09 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_09 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_10 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_10 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_11 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_11 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_2026_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_12 TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_2026_12 TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_2026_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_2026_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_2026_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE audit_logs_default; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_default TO parc_service;
GRANT SELECT ON TABLE public.audit_logs_default TO parc_readonly;
GRANT SELECT ON TABLE public.audit_logs_default TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_logs_default TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.audit_logs_default TO parc_tenant_admin_readonly;


--
-- Name: TABLE configuration_audit_logs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_audit_logs TO parc_service;
GRANT SELECT ON TABLE public.configuration_audit_logs TO parc_readonly;
GRANT ALL ON TABLE public.configuration_audit_logs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_audit_logs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_audit_logs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.configuration_audit_logs TO parc_tenant_admin_readonly;


--
-- Name: TABLE configuration_definitions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.configuration_definitions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_definitions TO parc_tenant_admin_platform;


--
-- Name: TABLE configuration_versions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_versions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configuration_versions TO parc_tenant_admin_platform;


--
-- Name: TABLE data_access_logs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.data_access_logs TO parc_service;
GRANT SELECT ON TABLE public.data_access_logs TO parc_readonly;
GRANT ALL ON TABLE public.data_access_logs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.data_access_logs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.data_access_logs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.data_access_logs TO parc_tenant_admin_readonly;


--
-- Name: TABLE feature_modules; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.feature_modules TO parc_service;
GRANT SELECT ON TABLE public.feature_modules TO parc_readonly;
GRANT ALL ON TABLE public.feature_modules TO parc_admin;
GRANT SELECT ON TABLE public.feature_modules TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.feature_modules TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.feature_modules TO parc_tenant_admin_readonly;


--
-- Name: TABLE feature_usage_limits; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.feature_usage_limits TO parc_service;
GRANT SELECT ON TABLE public.feature_usage_limits TO parc_readonly;
GRANT ALL ON TABLE public.feature_usage_limits TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.feature_usage_limits TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.feature_usage_limits TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.feature_usage_limits TO parc_tenant_admin_readonly;


--
-- Name: TABLE features; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.features TO parc_service;
GRANT SELECT ON TABLE public.features TO parc_readonly;
GRANT ALL ON TABLE public.features TO parc_admin;
GRANT SELECT ON TABLE public.features TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.features TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.features TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys TO parc_readonly;
GRANT ALL ON TABLE public.idempotency_keys TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2025_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_09 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2025_09 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2025_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2025_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2025_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_10 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2025_10 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2025_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2025_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2025_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_11 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2025_11 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2025_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2025_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2025_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_12 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2025_12 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2025_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2025_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2025_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_01; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_01 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_01 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_01 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_01 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_01 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_02; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_02 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_02 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_02 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_02 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_02 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_03; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_03 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_03 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_03 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_03 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_03 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_04; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_04 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_04 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_04 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_04 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_04 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_05; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_05 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_05 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_05 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_05 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_05 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_06; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_06 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_06 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_06 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_06 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_06 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_07; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_07 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_07 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_07 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_07 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_07 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_08; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_08 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_08 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_08 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_08 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_08 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_09 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_09 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_10 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_10 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_11 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_11 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_2026_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_12 TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_2026_12 TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_2026_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_2026_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_2026_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE idempotency_keys_default; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_default TO parc_service;
GRANT SELECT ON TABLE public.idempotency_keys_default TO parc_readonly;
GRANT SELECT ON TABLE public.idempotency_keys_default TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.idempotency_keys_default TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.idempotency_keys_default TO parc_tenant_admin_readonly;


--
-- Name: TABLE inbox_events; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inbox_events TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inbox_events TO parc_tenant_admin_platform;
GRANT SELECT,INSERT,UPDATE ON TABLE public.inbox_events TO parc_tenant_admin_worker;
GRANT SELECT ON TABLE public.inbox_events TO parc_tenant_admin_readonly;


--
-- Name: SEQUENCE knex_migrations_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_id_seq TO parc_tenant_admin_runtime;
GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_id_seq TO parc_tenant_admin_platform;
GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_id_seq TO parc_tenant_admin_worker;


--
-- Name: SEQUENCE knex_migrations_lock_index_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_lock_index_seq TO parc_tenant_admin_runtime;
GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_lock_index_seq TO parc_tenant_admin_platform;
GRANT SELECT,USAGE ON SEQUENCE public.knex_migrations_lock_index_seq TO parc_tenant_admin_worker;


--
-- Name: TABLE operation_actions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_actions TO parc_service;
GRANT SELECT ON TABLE public.operation_actions TO parc_readonly;
GRANT ALL ON TABLE public.operation_actions TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_actions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_actions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.operation_actions TO parc_tenant_admin_readonly;


--
-- Name: TABLE operation_approvals; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_approvals TO parc_service;
GRANT SELECT ON TABLE public.operation_approvals TO parc_readonly;
GRANT ALL ON TABLE public.operation_approvals TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_approvals TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_approvals TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.operation_approvals TO parc_tenant_admin_readonly;


--
-- Name: TABLE operation_attachments; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_attachments TO parc_service;
GRANT SELECT ON TABLE public.operation_attachments TO parc_readonly;
GRANT ALL ON TABLE public.operation_attachments TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_attachments TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_attachments TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.operation_attachments TO parc_tenant_admin_readonly;


--
-- Name: TABLE operation_comments; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_comments TO parc_service;
GRANT SELECT ON TABLE public.operation_comments TO parc_readonly;
GRANT ALL ON TABLE public.operation_comments TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_comments TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_comments TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.operation_comments TO parc_tenant_admin_readonly;


--
-- Name: TABLE operation_requests; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_requests TO parc_service;
GRANT SELECT ON TABLE public.operation_requests TO parc_readonly;
GRANT ALL ON TABLE public.operation_requests TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_requests TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_requests TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.operation_requests TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_event_attempts; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_event_attempts TO parc_service;
GRANT SELECT ON TABLE public.outbox_event_attempts TO parc_readonly;
GRANT ALL ON TABLE public.outbox_event_attempts TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_event_attempts TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_event_attempts TO parc_tenant_admin_platform;
GRANT SELECT,INSERT,UPDATE ON TABLE public.outbox_event_attempts TO parc_tenant_admin_worker;
GRANT SELECT ON TABLE public.outbox_event_attempts TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events TO parc_service;
GRANT SELECT ON TABLE public.outbox_events TO parc_readonly;
GRANT ALL ON TABLE public.outbox_events TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events TO parc_tenant_admin_platform;
GRANT SELECT,INSERT,UPDATE ON TABLE public.outbox_events TO parc_tenant_admin_worker;
GRANT SELECT ON TABLE public.outbox_events TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2025_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_09 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2025_09 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2025_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2025_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2025_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_10 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2025_10 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2025_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2025_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2025_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_11 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2025_11 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2025_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2025_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2025_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_12 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2025_12 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2025_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2025_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2025_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_01; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_01 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_01 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_01 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_01 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_01 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_02; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_02 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_02 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_02 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_02 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_02 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_03; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_03 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_03 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_03 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_03 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_03 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_04; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_04 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_04 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_04 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_04 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_04 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_05; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_05 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_05 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_05 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_05 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_05 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_06; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_06 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_06 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_06 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_06 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_06 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_07; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_07 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_07 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_07 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_07 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_07 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_08; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_08 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_08 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_08 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_08 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_08 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_09; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_09 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_09 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_09 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_09 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_09 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_10; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_10 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_10 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_10 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_10 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_10 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_11; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_11 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_11 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_11 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_11 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_11 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_2026_12; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_12 TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_2026_12 TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_2026_12 TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_2026_12 TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_2026_12 TO parc_tenant_admin_readonly;


--
-- Name: TABLE outbox_events_default; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_default TO parc_service;
GRANT SELECT ON TABLE public.outbox_events_default TO parc_readonly;
GRANT SELECT ON TABLE public.outbox_events_default TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.outbox_events_default TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.outbox_events_default TO parc_tenant_admin_readonly;


--
-- Name: TABLE provider_capabilities; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.provider_capabilities TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.provider_capabilities TO parc_tenant_admin_platform;


--
-- Name: TABLE provider_capability_availability_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT ON TABLE public.provider_capability_availability_history TO parc_tenant_admin_platform;


--
-- Name: TABLE provider_catalog; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.provider_catalog TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.provider_catalog TO parc_tenant_admin_platform;


--
-- Name: TABLE reconciliation_actions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_actions TO parc_service;
GRANT SELECT ON TABLE public.reconciliation_actions TO parc_readonly;
GRANT ALL ON TABLE public.reconciliation_actions TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_actions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_actions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.reconciliation_actions TO parc_tenant_admin_readonly;


--
-- Name: TABLE reconciliation_exceptions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_exceptions TO parc_service;
GRANT SELECT ON TABLE public.reconciliation_exceptions TO parc_readonly;
GRANT ALL ON TABLE public.reconciliation_exceptions TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_exceptions TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_exceptions TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.reconciliation_exceptions TO parc_tenant_admin_readonly;


--
-- Name: TABLE reconciliation_items; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_items TO parc_service;
GRANT SELECT ON TABLE public.reconciliation_items TO parc_readonly;
GRANT ALL ON TABLE public.reconciliation_items TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_items TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_items TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.reconciliation_items TO parc_tenant_admin_readonly;


--
-- Name: TABLE reconciliation_jobs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_jobs TO parc_service;
GRANT SELECT ON TABLE public.reconciliation_jobs TO parc_readonly;
GRANT ALL ON TABLE public.reconciliation_jobs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_jobs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_jobs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.reconciliation_jobs TO parc_tenant_admin_readonly;


--
-- Name: TABLE reconciliation_runs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_runs TO parc_service;
GRANT SELECT ON TABLE public.reconciliation_runs TO parc_readonly;
GRANT ALL ON TABLE public.reconciliation_runs TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_runs TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reconciliation_runs TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.reconciliation_runs TO parc_tenant_admin_readonly;


--
-- Name: TABLE security_events; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.security_events TO parc_service;
GRANT SELECT ON TABLE public.security_events TO parc_readonly;
GRANT ALL ON TABLE public.security_events TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.security_events TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.security_events TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.security_events TO parc_tenant_admin_readonly;


--
-- Name: TABLE support_categories; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_categories TO parc_service;
GRANT SELECT ON TABLE public.support_categories TO parc_readonly;
GRANT ALL ON TABLE public.support_categories TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_categories TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_categories TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.support_categories TO parc_tenant_admin_readonly;


--
-- Name: TABLE support_ticket_assignments; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_assignments TO parc_service;
GRANT SELECT ON TABLE public.support_ticket_assignments TO parc_readonly;
GRANT ALL ON TABLE public.support_ticket_assignments TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_assignments TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_assignments TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.support_ticket_assignments TO parc_tenant_admin_readonly;


--
-- Name: TABLE support_ticket_events; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_events TO parc_service;
GRANT SELECT ON TABLE public.support_ticket_events TO parc_readonly;
GRANT ALL ON TABLE public.support_ticket_events TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_events TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_events TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.support_ticket_events TO parc_tenant_admin_readonly;


--
-- Name: TABLE support_ticket_messages; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_messages TO parc_service;
GRANT SELECT ON TABLE public.support_ticket_messages TO parc_readonly;
GRANT ALL ON TABLE public.support_ticket_messages TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_messages TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_ticket_messages TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.support_ticket_messages TO parc_tenant_admin_readonly;


--
-- Name: TABLE support_tickets; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_tickets TO parc_service;
GRANT SELECT ON TABLE public.support_tickets TO parc_readonly;
GRANT ALL ON TABLE public.support_tickets TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_tickets TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.support_tickets TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.support_tickets TO parc_tenant_admin_readonly;


--
-- Name: TABLE system_configurations; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_configurations TO parc_service;
GRANT SELECT ON TABLE public.system_configurations TO parc_readonly;
GRANT ALL ON TABLE public.system_configurations TO parc_admin;
GRANT SELECT ON TABLE public.system_configurations TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_configurations TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.system_configurations TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_api_credentials; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_api_credentials TO parc_service;
GRANT SELECT ON TABLE public.tenant_api_credentials TO parc_readonly;
GRANT ALL ON TABLE public.tenant_api_credentials TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_api_credentials TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_api_credentials TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_api_credentials TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_commercial_agreements; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_commercial_agreements TO parc_service;
GRANT SELECT ON TABLE public.tenant_commercial_agreements TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_commercial_agreements TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_commercial_agreements TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_commercial_agreements TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_configuration_publications; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_configuration_publications TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_configuration_publications TO parc_tenant_admin_platform;


--
-- Name: TABLE tenant_configurations; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_configurations TO parc_service;
GRANT SELECT ON TABLE public.tenant_configurations TO parc_readonly;
GRANT ALL ON TABLE public.tenant_configurations TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_configurations TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_configurations TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_configurations TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_domains; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_domains TO parc_service;
GRANT SELECT ON TABLE public.tenant_domains TO parc_readonly;
GRANT ALL ON TABLE public.tenant_domains TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_domains TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_domains TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_domains TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_feature_overrides; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_overrides TO parc_service;
GRANT SELECT ON TABLE public.tenant_feature_overrides TO parc_readonly;
GRANT ALL ON TABLE public.tenant_feature_overrides TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_overrides TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_overrides TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_feature_overrides TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_feature_usage; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_usage TO parc_service;
GRANT SELECT ON TABLE public.tenant_feature_usage TO parc_readonly;
GRANT ALL ON TABLE public.tenant_feature_usage TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_usage TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_feature_usage TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_feature_usage TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_profiles; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_profiles TO parc_service;
GRANT SELECT ON TABLE public.tenant_profiles TO parc_readonly;
GRANT ALL ON TABLE public.tenant_profiles TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_profiles TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_profiles TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_profiles TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_provider_selection_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_provider_selection_history TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_provider_selection_history TO parc_tenant_admin_platform;


--
-- Name: TABLE tenant_provider_selections; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_provider_selections TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_provider_selections TO parc_tenant_admin_platform;


--
-- Name: TABLE tenant_revenue_settlement_configuration_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configuration_history TO parc_service;
GRANT SELECT ON TABLE public.tenant_revenue_settlement_configuration_history TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configuration_history TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configuration_history TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_revenue_settlement_configuration_history TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_revenue_settlement_configurations; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configurations TO parc_service;
GRANT SELECT ON TABLE public.tenant_revenue_settlement_configurations TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configurations TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_settlement_configurations TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_revenue_settlement_configurations TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_revenue_share_rule_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rule_history TO parc_service;
GRANT SELECT ON TABLE public.tenant_revenue_share_rule_history TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rule_history TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rule_history TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_revenue_share_rule_history TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_revenue_share_rules; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rules TO parc_service;
GRANT SELECT ON TABLE public.tenant_revenue_share_rules TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rules TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_rules TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_revenue_share_rules TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_revenue_share_tiers; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_tiers TO parc_service;
GRANT SELECT ON TABLE public.tenant_revenue_share_tiers TO parc_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_tiers TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_revenue_share_tiers TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_revenue_share_tiers TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_service_configurations; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_service_configurations TO parc_service;
GRANT SELECT ON TABLE public.tenant_service_configurations TO parc_readonly;
GRANT ALL ON TABLE public.tenant_service_configurations TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_service_configurations TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_service_configurations TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_service_configurations TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_settings; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_settings TO parc_service;
GRANT SELECT ON TABLE public.tenant_settings TO parc_readonly;
GRANT ALL ON TABLE public.tenant_settings TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_settings TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_settings TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_settings TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_status_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_status_history TO parc_service;
GRANT SELECT ON TABLE public.tenant_status_history TO parc_readonly;
GRANT ALL ON TABLE public.tenant_status_history TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_status_history TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_status_history TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_status_history TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_tiers; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_tiers TO parc_service;
GRANT SELECT ON TABLE public.tenant_tiers TO parc_readonly;
GRANT ALL ON TABLE public.tenant_tiers TO parc_admin;
GRANT SELECT ON TABLE public.tenant_tiers TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_tiers TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_tiers TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenant_webhooks; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_webhooks TO parc_service;
GRANT SELECT ON TABLE public.tenant_webhooks TO parc_readonly;
GRANT ALL ON TABLE public.tenant_webhooks TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_webhooks TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenant_webhooks TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenant_webhooks TO parc_tenant_admin_readonly;


--
-- Name: TABLE tenants; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenants TO parc_service;
GRANT SELECT ON TABLE public.tenants TO parc_readonly;
GRANT ALL ON TABLE public.tenants TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenants TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tenants TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tenants TO parc_tenant_admin_readonly;


--
-- Name: TABLE tier_features; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tier_features TO parc_service;
GRANT SELECT ON TABLE public.tier_features TO parc_readonly;
GRANT ALL ON TABLE public.tier_features TO parc_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tier_features TO parc_tenant_admin_runtime;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tier_features TO parc_tenant_admin_platform;
GRANT SELECT ON TABLE public.tier_features TO parc_tenant_admin_readonly;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO parc_service;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO parc_readonly;


--
-- PostgreSQL database dump complete
--

