import type { Knex } from "knex";

export interface ReceiveInboxEvent {
  eventId: string;
  sourceService: string;
  eventType: string;
  eventVersion: number;
  tenantId?: string;
  aggregateType?: string;
  aggregateId?: string;
  correlationId?: string;
  causationId?: string;
  payload: Record<string, unknown>;
  headers?: Record<string, unknown>;
}

export interface InboxReceipt {
  id: string;
  duplicate: boolean;
}

interface InboxRow {
  id: string;
}

export class InboxRepository {
  public constructor(private readonly database: Knex | Knex.Transaction) {}

  public async receive(event: ReceiveInboxEvent): Promise<InboxReceipt> {
    const inserted = await this.database<Record<string, unknown>, InboxRow[]>(
      "inbox_events",
    )
      .insert({
        event_id: event.eventId,
        source_service: event.sourceService,
        event_type: event.eventType,
        event_version: event.eventVersion,
        tenant_id: event.tenantId ?? null,
        aggregate_type: event.aggregateType ?? null,
        aggregate_id: event.aggregateId ?? null,
        correlation_id: event.correlationId ?? null,
        causation_id: event.causationId ?? null,
        payload: event.payload,
        headers: event.headers ?? {},
      })
      .onConflict(["source_service", "event_id"])
      .ignore()
      .returning("id");
    if (inserted[0] !== undefined)
      return { id: String(inserted[0].id), duplicate: false };

    const existing = (await this.database("inbox_events")
      .select("id")
      .where({ source_service: event.sourceService, event_id: event.eventId })
      .first()) as InboxRow | undefined;
    if (existing === undefined)
      throw new Error("Inbox deduplication record is not visible");
    return { id: existing.id, duplicate: true };
  }

  public async markProcessed(id: string): Promise<boolean> {
    return (
      (await this.database("inbox_events")
        .where({ id })
        .whereIn("status", ["RECEIVED", "PROCESSING", "FAILED"])
        .update({
          status: "PROCESSED",
          processed_at: this.database.fn.now(),
        })) === 1
    );
  }
}
