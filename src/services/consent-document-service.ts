import { createHash, randomUUID } from "node:crypto";
import type { Knex } from "knex";
import { withTenantTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { IdempotencyRepository } from "../repositories/idempotency-repository.js";
import type { ApprovalService } from "./approval-service.js";

export interface ConsentDocumentView {
  id: string;
  tenant_id: string;
  consent_type: string;
  document_version: string;
  title: string;
  purpose?: string;
  channel: string;
  policy_uri: string;
  evidence_digest: string;
  required_at_registration: boolean;
}
export interface ConsentDocumentCatalogueView extends ConsentDocumentView {
  status: string;
  sort_order: number;
  effective_from?: string;
  effective_until?: string;
  published_at?: string;
}
interface ConsentDocumentRow extends Record<string, unknown> {
  id: string;
  tenant_id: string;
  consent_type: string;
  document_version: string;
  title: string;
  purpose: string | null;
  channel: string;
  policy_uri: string;
  evidence_digest: string;
  required_at_registration: boolean;
  sort_order: number;
  status: string;
  effective_from: Date | string | null;
  effective_until: Date | string | null;
  published_at: Date | string | null;
}

export class ConsentDocumentService {
  public constructor(
    private readonly database: Knex,
    private readonly approvals: ApprovalService,
  ) {}

  public listCurrent(tenantId: string): Promise<ConsentDocumentView[]> {
    return withTenantTransaction(this.database, tenantId, async (tx) =>
      (
        await tx<ConsentDocumentRow>("tenant_consent_documents")
          .where({ tenant_id: tenantId, status: "PUBLISHED" })
          .whereNull("deleted_at")
          .where("effective_from", "<=", tx.fn.now())
          .where(
            (query) =>
              void query
                .whereNull("effective_until")
                .orWhere("effective_until", ">", tx.fn.now()),
          )
          .orderBy("required_at_registration", "desc")
          .orderBy("sort_order")
          .select("*")
      ).map(view),
    );
  }

  public listAll(tenantId: string): Promise<ConsentDocumentCatalogueView[]> {
    return withTenantTransaction(this.database, tenantId, async (tx) =>
      (
        await tx<ConsentDocumentRow>("tenant_consent_documents")
          .where({ tenant_id: tenantId })
          .whereNull("deleted_at")
          .orderBy("consent_type")
          .orderBy("created_at", "desc")
          .select("*")
      ).map(catalogueView),
    );
  }

  public async validate(
    tenantId: string,
    consentIds: readonly string[],
  ): Promise<ConsentDocumentView[]> {
    const current = await this.listCurrent(tenantId);
    const selected = current.filter((document) =>
      consentIds.includes(document.id),
    );
    if (selected.length !== new Set(consentIds).size)
      throw new ApiError(
        422,
        "INVALID_CONSENT_DOCUMENTS",
        "One or more consent documents are unavailable",
      );
    const missingRequired = current.filter(
      (document) =>
        document.required_at_registration && !consentIds.includes(document.id),
    );
    if (missingRequired.length > 0)
      throw new ApiError(
        422,
        "REQUIRED_CONSENT_MISSING",
        "All required registration consents must be accepted",
      );
    return selected;
  }

  public createDraft(input: {
    tenantId: string;
    consentType: string;
    documentVersion: string;
    title: string;
    purpose?: string;
    channel: string;
    policyUri: string;
    evidenceDigest: string;
    requiredAtRegistration: boolean;
    sortOrder: number;
    actorId: string;
    actorType: "TENANT_ADMIN" | "PLATFORM_ADMIN";
    idempotencyKey: string;
    correlationId: string;
  }): Promise<object> {
    return withTenantTransaction(this.database, input.tenantId, async (tx) => {
      const idempotency = new IdempotencyRepository(tx);
      const claim = await idempotency.claim({
        tenantId: input.tenantId,
        key: `consent-document-draft:${input.idempotencyKey}`,
        requestHash: createHash("sha256")
          .update(
            JSON.stringify({
              consentType: input.consentType,
              documentVersion: input.documentVersion,
              title: input.title,
              purpose: input.purpose ?? null,
              channel: input.channel,
              policyUri: input.policyUri,
              evidenceDigest: input.evidenceDigest,
              requiredAtRegistration: input.requiredAtRegistration,
              sortOrder: input.sortOrder,
            }),
          )
          .digest("hex"),
        expiresAt: new Date(Date.now() + 86_400_000),
      });
      if (!claim.created) return claim.record.response_body as object;
      const id = randomUUID();
      const [row] = await tx<ConsentDocumentRow>("tenant_consent_documents")
        .insert({
          id,
          tenant_id: input.tenantId,
          consent_type: input.consentType,
          document_version: input.documentVersion,
          title: input.title,
          purpose: input.purpose ?? null,
          channel: input.channel,
          policy_uri: input.policyUri,
          evidence_digest: input.evidenceDigest,
          required_at_registration: input.requiredAtRegistration,
          sort_order: input.sortOrder,
          created_by: input.actorId,
        })
        .returning<ConsentDocumentRow[]>("*");
      if (!row) throw new Error("Consent document insert returned no row");
      await tx("audit_logs").insert({
        tenant_id: input.tenantId,
        actor_id: input.actorId,
        actor_type: input.actorType,
        action: "CREATE",
        resource_type: "tenant_consent_document",
        resource_id: row.id,
        new_values: {
          consent_type: row.consent_type,
          document_version: row.document_version,
          status: "DRAFT",
          evidence_digest: row.evidence_digest,
        },
        correlation_id: input.correlationId,
      });
      const result = {
        ...view(row),
        status: "DRAFT",
        approval_binding: binding(row),
      };
      await idempotency.complete({
        id: claim.record.id,
        responseStatus: 201,
        responseBody: result,
        resourceType: "tenant_consent_document",
        resourceId: row.id,
      });
      return result;
    });
  }

  public async publish(input: {
    tenantId: string;
    documentId: string;
    approvalId: string;
    actorId: string;
    idempotencyKey: string;
    correlationId: string;
  }): Promise<ConsentDocumentView> {
    const draft = await withTenantTransaction(
      this.database,
      input.tenantId,
      (tx) =>
        tx<ConsentDocumentRow>("tenant_consent_documents")
          .where({ id: input.documentId, tenant_id: input.tenantId })
          .first(),
    );
    if (!draft)
      throw new ApiError(
        404,
        "CONSENT_DOCUMENT_NOT_FOUND",
        "Consent document was not found",
      );
    if (draft.status !== "DRAFT")
      throw new ApiError(
        409,
        "CONSENT_DOCUMENT_NOT_DRAFT",
        "Only a draft can be published",
      );
    await this.approvals.consume({
      scope: "TENANT",
      tenantId: input.tenantId,
      approvalId: input.approvalId,
      serviceName: "parc-tenant-admin",
      binding: binding(draft),
      idempotencyKey: input.idempotencyKey,
      correlationId: input.correlationId,
    });
    return withTenantTransaction(this.database, input.tenantId, async (tx) => {
      await tx("tenant_consent_documents")
        .where({
          tenant_id: input.tenantId,
          consent_type: draft.consent_type,
          channel: draft.channel,
          status: "PUBLISHED",
        })
        .update({
          status: "RETIRED",
          effective_until: tx.fn.now(),
          updated_at: tx.fn.now(),
        });
      const [published] = await tx<ConsentDocumentRow>(
        "tenant_consent_documents",
      )
        .where({ id: input.documentId, status: "DRAFT" })
        .update({
          status: "PUBLISHED",
          approval_id: input.approvalId,
          published_by: input.actorId,
          published_at: tx.fn.now(),
          effective_from: tx.fn.now(),
          updated_at: tx.fn.now(),
        })
        .returning<ConsentDocumentRow[]>("*");
      if (!published)
        throw new ApiError(
          409,
          "CONSENT_DOCUMENT_NOT_DRAFT",
          "Consent document changed concurrently",
        );
      await tx("audit_logs").insert({
        tenant_id: input.tenantId,
        actor_id: input.actorId,
        actor_type: "TENANT_ADMIN",
        action: "UPDATE",
        resource_type: "tenant_consent_document",
        resource_id: published.id,
        old_values: { status: "DRAFT" },
        new_values: {
          status: "PUBLISHED",
          document_version: published.document_version,
          evidence_digest: published.evidence_digest,
        },
        correlation_id: input.correlationId,
        metadata: { approval_id: input.approvalId },
      });
      return view(published);
    });
  }
}

function catalogueView(row: ConsentDocumentRow): ConsentDocumentCatalogueView {
  return {
    ...view(row),
    status: row.status,
    sort_order: row.sort_order,
    ...(row.effective_from
      ? { effective_from: new Date(row.effective_from).toISOString() }
      : {}),
    ...(row.effective_until
      ? { effective_until: new Date(row.effective_until).toISOString() }
      : {}),
    ...(row.published_at
      ? { published_at: new Date(row.published_at).toISOString() }
      : {}),
  };
}

function binding(row: ConsentDocumentRow) {
  return {
    action: "CONSENT_DOCUMENT_PUBLISH",
    resourceType: "tenant_consent_document",
    resourceId: String(row.id),
    payloadHash: createHash("sha256")
      .update(
        JSON.stringify({
          id: row.id,
          tenant_id: row.tenant_id,
          consent_type: row.consent_type,
          document_version: row.document_version,
          policy_uri: row.policy_uri,
          evidence_digest: row.evidence_digest,
          required_at_registration: row.required_at_registration,
        }),
      )
      .digest("hex"),
  };
}

function view(row: ConsentDocumentRow): ConsentDocumentView {
  return {
    id: String(row.id),
    tenant_id: String(row.tenant_id),
    consent_type: String(row.consent_type),
    document_version: String(row.document_version),
    title: String(row.title),
    ...(row.purpose ? { purpose: row.purpose } : {}),
    channel: String(row.channel),
    policy_uri: String(row.policy_uri),
    evidence_digest: String(row.evidence_digest).trim(),
    required_at_registration: Boolean(row.required_at_registration),
  };
}
