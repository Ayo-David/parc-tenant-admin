import type { Knex } from "knex";

export class OutboxRepository {
  public constructor(private readonly transaction: Knex.Transaction) {}

  public async add(input: {
    tenantId: string | null;
    aggregateType: string;
    aggregateId: string;
    eventType: string;
    idempotencyKey: string;
    correlationId: string;
    causationId?: string;
    payload: Record<string, unknown>;
  }): Promise<string> {
    const [row] = await this.transaction("outbox_events")
      .insert({
        tenant_id: input.tenantId,
        aggregate_type: input.aggregateType,
        aggregate_id: input.aggregateId,
        event_type: input.eventType,
        event_version: 1,
        idempotency_key: input.idempotencyKey,
        correlation_id: input.correlationId,
        causation_id: input.causationId ?? null,
        payload: input.payload,
      })
      .returning<{ id: string }[]>("id");
    if (row === undefined) throw new Error("Outbox insert returned no record");
    return row.id;
  }
}
