import { createHash, randomUUID } from "node:crypto";
import type { Knex } from "knex";
import { withTenantTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";

export class CustomerSupportService {
  public constructor(private readonly database: Knex) {}

  public listFaqs(tenantId: string): Promise<unknown[]> {
    return withTenantTransaction(this.database, tenantId, (tx) =>
      tx("support_faqs as f")
        .leftJoin("support_categories as c", "c.id", "f.category_id")
        .where("f.tenant_id", tenantId)
        .where("f.status", "PUBLISHED")
        .whereNull("f.deleted_at")
        .where("f.effective_from", "<=", tx.fn.now())
        .where((builder) => {
          void builder
            .whereNull("f.effective_until")
            .orWhere("f.effective_until", ">", tx.fn.now());
        })
        .orderBy("f.sort_order")
        .orderBy("f.created_at")
        .select(
          "f.id",
          "f.question",
          "f.answer",
          "f.version",
          "c.code as category_code",
          "c.name as category_name",
        ),
    );
  }

  public listTickets(tenantId: string, customerId: string): Promise<unknown[]> {
    return withTenantTransaction(this.database, tenantId, (tx) =>
      tx("support_tickets")
        .where({ tenant_id: tenantId, customer_id: customerId })
        .orderBy("created_at", "desc")
        .select(
          "id",
          "ticket_reference",
          "subject",
          "status",
          "priority",
          "opened_at",
          "updated_at",
        ),
    );
  }

  public createTicket(input: {
    tenantId: string;
    customerId: string;
    categoryId?: string;
    subject: string;
    description: string;
    idempotencyKey: string;
  }): Promise<{ id: string; ticket_reference: string; status: string }> {
    return withTenantTransaction(this.database, input.tenantId, async (tx) => {
      const requestHash = createHash("sha256")
        .update(
          JSON.stringify({
            customerId: input.customerId,
            categoryId: input.categoryId ?? null,
            subject: input.subject,
            description: input.description,
          }),
        )
        .digest("hex");
      await tx.raw("SELECT pg_advisory_xact_lock(hashtextextended(?, 0))", [
        `${input.tenantId}:support-ticket:${input.idempotencyKey}`,
      ]);
      const existing = await tx("idempotency_keys")
        .where({
          tenant_id: input.tenantId,
          idempotency_key: `support-ticket:${input.idempotencyKey}`,
        })
        .where("expires_at", ">", tx.fn.now())
        .orderBy("created_at", "desc")
        .first<{
          request_hash: string;
          response_body: {
            id: string;
            ticket_reference: string;
            status: string;
          } | null;
        }>();
      if (existing) {
        if (existing.request_hash !== requestHash)
          throw new ApiError(
            409,
            "IDEMPOTENCY_CONFLICT",
            "Idempotency key was used for another request",
          );
        if (!existing.response_body)
          throw new ApiError(
            409,
            "REQUEST_IN_PROGRESS",
            "Request is still processing",
          );
        return existing.response_body;
      }
      if (input.categoryId) {
        const category = await tx("support_categories")
          .where({ id: input.categoryId, is_active: true })
          .whereNull("deleted_at")
          .where((builder) => {
            void builder
              .whereNull("tenant_id")
              .orWhere("tenant_id", input.tenantId);
          })
          .first<{ id: string }>("id");
        if (!category)
          throw new ApiError(422, "INVALID_CATEGORY", "Category unavailable");
      }
      const id = randomUUID();
      const ticketReference = `SUP-${id.slice(0, 8).toUpperCase()}`;
      await tx("support_tickets").insert({
        id,
        tenant_id: input.tenantId,
        customer_id: input.customerId,
        ...(input.categoryId ? { category_id: input.categoryId } : {}),
        ticket_reference: ticketReference,
        subject: input.subject,
        description: input.description,
        channel: "IN_APP",
      });
      const result = { id, ticket_reference: ticketReference, status: "OPEN" };
      await tx("idempotency_keys").insert({
        tenant_id: input.tenantId,
        idempotency_key: `support-ticket:${input.idempotencyKey}`,
        request_hash: requestHash,
        status: "COMPLETED",
        response_status: 201,
        response_body: result,
        resource_type: "support_ticket",
        resource_id: id,
        expires_at: new Date(Date.now() + 24 * 60 * 60_000),
      });
      return result;
    });
  }
}
