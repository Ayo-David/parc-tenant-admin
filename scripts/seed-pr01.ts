import { createHash, randomUUID } from "node:crypto";
import knex from "knex";
import { z } from "zod";

const config = z
  .object({
    NODE_ENV: z.enum(["development", "test"]),
    DATABASE_URL: z.string().url(),
    PR01_TENANT_A_ID: z.string().uuid(),
    PR01_TENANT_B_ID: z.string().uuid(),
  })
  .parse(process.env);

const database = knex({ client: "pg", connection: config.DATABASE_URL });
interface ConsentDraft {
  id: string;
  tenant_id: string;
  consent_type: string;
  document_version: string;
  policy_uri: string;
  evidence_digest: string;
  required_at_registration: boolean;
}
const fixtures = [
  {
    id: config.PR01_TENANT_A_ID,
    tenant_code: "PR01-TENANT-A",
    legal_name: "PR-01 Tenant Alpha Microfinance Bank",
    trading_name: "PR-01 Alpha",
    contact_email: "operations-alpha@pr01.parc.invalid",
    contact_phone: "+2348010000001",
  },
  {
    id: config.PR01_TENANT_B_ID,
    tenant_code: "PR01-TENANT-B",
    legal_name: "PR-01 Tenant Beta Microfinance Bank",
    trading_name: "PR-01 Beta",
    contact_email: "operations-beta@pr01.parc.invalid",
    contact_phone: "+2348010000002",
  },
] as const;

try {
  await database.transaction(async (transaction) => {
    for (const fixture of fixtures) {
      await transaction("tenants")
        .insert({
          id: fixture.id,
          tenant_code: fixture.tenant_code,
          legal_name: fixture.legal_name,
          trading_name: fixture.trading_name,
          tenant_type: "MFB",
          country_code: "NG",
          currency_code: "NGN",
          status: "ACTIVE",
          onboarding_completed_at: transaction.fn.now(),
          activated_at: transaction.fn.now(),
          metadata: JSON.stringify({ fixture: "PR-01", disposable: true }),
        })
        .onConflict("id")
        .merge({
          tenant_code: fixture.tenant_code,
          legal_name: fixture.legal_name,
          trading_name: fixture.trading_name,
          status: "ACTIVE",
          updated_at: transaction.fn.now(),
        });

      await transaction("tenant_profiles")
        .insert({
          tenant_id: fixture.id,
          primary_email: fixture.contact_email,
          support_email: fixture.contact_email,
          phone_number: fixture.contact_phone,
          contact_person_name: "PR-01 Operator",
          contact_person_email: fixture.contact_email,
          contact_person_phone: fixture.contact_phone,
          branding: JSON.stringify({ fixture: "PR-01" }),
        })
        .onConflict("tenant_id")
        .merge({
          primary_email: fixture.contact_email,
          support_email: fixture.contact_email,
          phone_number: fixture.contact_phone,
          updated_at: transaction.fn.now(),
        });

      const adminEmail = `consent-maker-${fixture.id}@pr01.parc.invalid`;
      const [maker] = await transaction("admin_users")
        .insert({
          tenant_id: fixture.id,
          email: adminEmail,
          first_name: "Consent",
          last_name: "Fixture Maker",
          status: "ACTIVE",
          metadata: JSON.stringify({
            fixture: "PR-01",
            purpose: "consent-publication",
          }),
        })
        .onConflict("email")
        .merge({
          status: "ACTIVE",
          deleted_at: null,
          updated_at: transaction.fn.now(),
        })
        .returning<{ id: string }[]>("id");
      if (!maker) throw new Error("Consent fixture maker was not available");
      const drafts = await transaction("tenant_consent_documents")
        .where({ tenant_id: fixture.id, status: "DRAFT" })
        .orderBy("sort_order")
        .select<ConsentDraft[]>(
          "id",
          "tenant_id",
          "consent_type",
          "document_version",
          "policy_uri",
          "evidence_digest",
          "required_at_registration",
        );
      for (const draft of drafts) {
        const binding = {
          id: draft.id,
          tenant_id: draft.tenant_id,
          consent_type: draft.consent_type,
          document_version: draft.document_version,
          policy_uri: draft.policy_uri,
          evidence_digest: String(draft.evidence_digest).trim(),
          required_at_registration: draft.required_at_registration,
        };
        const approvalId = randomUUID();
        await transaction("operation_requests").insert({
          id: approvalId,
          tenant_id: fixture.id,
          operation_reference: `PR01-CONSENT-${draft.id}`,
          operation_type: "CONSENT_DOCUMENT_PUBLISH",
          resource_type: "tenant_consent_document",
          resource_id: draft.id,
          requested_by: maker.id,
          status: "CONSUMED",
          reason: "Deterministic PR-01 consent catalogue publication",
          request_data: {},
          scope: "TENANT",
          payload_hash: createHash("sha256")
            .update(JSON.stringify(binding))
            .digest("hex"),
          expires_at: new Date(Date.now() + 86_400_000),
          decided_at: transaction.fn.now(),
          consumed_at: transaction.fn.now(),
          consumed_by_service: "parc-tenant-admin",
          consumption_idempotency_key: `pr01-consent:${draft.id}`,
        });
        await transaction("tenant_consent_documents")
          .where({ id: draft.id })
          .update({
            status: "PUBLISHED",
            approval_id: approvalId,
            published_by: maker.id,
            published_at: transaction.fn.now(),
            effective_from: transaction.fn.now(),
            updated_at: transaction.fn.now(),
          });
      }

      const historyExists = await transaction("tenant_status_history")
        .where({ tenant_id: fixture.id, new_status: "ACTIVE" })
        .first<{ id: string }>("id");
      if (!historyExists)
        await transaction("tenant_status_history").insert({
          tenant_id: fixture.id,
          previous_status: "PENDING",
          new_status: "ACTIVE",
          reason: "Deterministic PR-01 load fixture",
          metadata: JSON.stringify({ fixture: "PR-01", disposable: true }),
        });
    }
  });
  console.log(
    JSON.stringify({
      fixture: "PR-01",
      tenants: fixtures.map(({ id, tenant_code }) => ({ id, tenant_code })),
    }),
  );
} finally {
  await database.destroy();
}
