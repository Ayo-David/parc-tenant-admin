import type { Knex } from "knex";

export const config = { transaction: false };

export async function up(knex: Knex): Promise<void> {
  if (await knex.schema.hasColumn("operation_requests", "payload_hash")) return;
  await knex.raw(
    "ALTER TYPE public.operation_status_enum ADD VALUE IF NOT EXISTS 'EXPIRED'",
  );
  await knex.raw(
    "ALTER TYPE public.operation_status_enum ADD VALUE IF NOT EXISTS 'CONSUMED'",
  );

  await knex.raw(`
    ALTER TABLE public.operation_requests ALTER COLUMN tenant_id DROP NOT NULL;
    ALTER TABLE public.operation_requests
      ADD COLUMN IF NOT EXISTS scope varchar(20) NOT NULL DEFAULT 'TENANT',
      ADD COLUMN IF NOT EXISTS payload_hash char(64),
      ADD COLUMN IF NOT EXISTS amount_minor bigint,
      ADD COLUMN IF NOT EXISTS currency char(3),
      ADD COLUMN IF NOT EXISTS expires_at timestamptz,
      ADD COLUMN IF NOT EXISTS required_approval_count integer NOT NULL DEFAULT 1,
      ADD COLUMN IF NOT EXISTS decided_at timestamptz,
      ADD COLUMN IF NOT EXISTS consumed_at timestamptz,
      ADD COLUMN IF NOT EXISTS consumed_by_service varchar(100),
      ADD COLUMN IF NOT EXISTS consumption_idempotency_key varchar(255);

    UPDATE public.operation_requests
       SET payload_hash = encode(digest(
             operation_type || ':' || resource_type || ':' || resource_id::text || ':' || request_data::text,
             'sha256'), 'hex')
     WHERE payload_hash IS NULL;
    UPDATE public.operation_requests
       SET expires_at = created_at + interval '7 days'
     WHERE expires_at IS NULL;
    ALTER TABLE public.operation_requests ALTER COLUMN payload_hash SET NOT NULL;
    ALTER TABLE public.operation_requests ALTER COLUMN expires_at SET NOT NULL;

    ALTER TABLE public.operation_requests
      ADD CONSTRAINT chk_operation_scope_tenant
        CHECK ((scope = 'TENANT' AND tenant_id IS NOT NULL) OR (scope = 'PLATFORM' AND tenant_id IS NULL)) NOT VALID,
      ADD CONSTRAINT chk_operation_payload_hash
        CHECK (payload_hash ~ '^[a-f0-9]{64}$') NOT VALID,
      ADD CONSTRAINT chk_operation_money_pair
        CHECK ((amount_minor IS NULL AND currency IS NULL) OR
               (amount_minor IS NOT NULL AND amount_minor >= 0 AND currency ~ '^[A-Z]{3}$')) NOT VALID,
      ADD CONSTRAINT chk_operation_required_approvals
        CHECK (required_approval_count BETWEEN 1 AND 3) NOT VALID,
      ADD CONSTRAINT chk_operation_consumption
        CHECK ((consumed_at IS NULL AND consumed_by_service IS NULL AND consumption_idempotency_key IS NULL) OR
               (consumed_at IS NOT NULL AND consumed_by_service IS NOT NULL AND consumption_idempotency_key IS NOT NULL)) NOT VALID;
    ALTER TABLE public.operation_requests VALIDATE CONSTRAINT chk_operation_scope_tenant;
    ALTER TABLE public.operation_requests VALIDATE CONSTRAINT chk_operation_payload_hash;
    ALTER TABLE public.operation_requests VALIDATE CONSTRAINT chk_operation_money_pair;
    ALTER TABLE public.operation_requests VALIDATE CONSTRAINT chk_operation_required_approvals;
    ALTER TABLE public.operation_requests VALIDATE CONSTRAINT chk_operation_consumption;

    ALTER TABLE public.operation_actions ALTER COLUMN performed_by DROP NOT NULL;
    ALTER TABLE public.operation_actions ADD COLUMN IF NOT EXISTS performed_by_service varchar(100);
    ALTER TABLE public.operation_actions ADD CONSTRAINT chk_operation_action_actor
      CHECK ((performed_by IS NOT NULL)::integer + (performed_by_service IS NOT NULL)::integer = 1) NOT VALID;
    ALTER TABLE public.operation_actions VALIDATE CONSTRAINT chk_operation_action_actor;

    CREATE UNIQUE INDEX IF NOT EXISTS uq_operation_approval_checker
      ON public.operation_approvals (operation_request_id, approver_id);
    CREATE UNIQUE INDEX IF NOT EXISTS uq_operation_consumption_idempotency
      ON public.operation_requests (consumed_by_service, consumption_idempotency_key)
      WHERE consumption_idempotency_key IS NOT NULL;
    CREATE INDEX IF NOT EXISTS idx_operation_pending_expiry
      ON public.operation_requests (expires_at, tenant_id) WHERE status IN ('PENDING', 'IN_REVIEW');
    CREATE INDEX IF NOT EXISTS idx_operation_consumed
      ON public.operation_requests (consumed_by_service, consumed_at DESC) WHERE status = 'CONSUMED';

    CREATE OR REPLACE FUNCTION public.enforce_operation_binding_immutability() RETURNS trigger
      LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
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
    DROP TRIGGER IF EXISTS trg_operation_binding_immutable ON public.operation_requests;
    CREATE TRIGGER trg_operation_binding_immutable BEFORE UPDATE ON public.operation_requests
      FOR EACH ROW EXECUTE FUNCTION public.enforce_operation_binding_immutability();

    CREATE OR REPLACE FUNCTION public.enforce_maker_checker() RETURNS trigger
      LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
    BEGIN
      IF EXISTS (SELECT 1 FROM public.operation_requests r
                 WHERE r.id = NEW.operation_request_id AND r.requested_by = NEW.approver_id) THEN
        RAISE EXCEPTION 'maker cannot approve own request' USING ERRCODE = '23514';
      END IF;
      RETURN NEW;
    END $$;
    DROP TRIGGER IF EXISTS trg_operation_maker_checker ON public.operation_approvals;
    CREATE TRIGGER trg_operation_maker_checker BEFORE INSERT OR UPDATE ON public.operation_approvals
      FOR EACH ROW EXECUTE FUNCTION public.enforce_maker_checker();

    GRANT SELECT, INSERT, UPDATE, DELETE ON public.operation_requests, public.operation_approvals,
      public.operation_actions TO parc_tenant_admin_platform;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.operation_requests, public.operation_approvals,
      public.operation_actions TO parc_tenant_admin_runtime;
  `);
}

export function down(): Promise<never> {
  return Promise.reject(new Error("Bound approval controls are forward-only"));
}
