import type { Knex } from "knex";

export interface IdempotencyRecord {
  id: string;
  tenant_id: string | null;
  idempotency_key: string;
  request_hash: string;
  status: "PROCESSING" | "COMPLETED" | "FAILED";
  response_status: number | null;
  response_body: unknown;
  resource_type: string | null;
  resource_id: string | null;
  expires_at: Date;
}

export class IdempotencyRepository {
  public constructor(private readonly transaction: Knex.Transaction) {}

  public async claim(input: {
    tenantId: string | null;
    key: string;
    requestHash: string;
    expiresAt: Date;
  }): Promise<{ created: boolean; record: IdempotencyRecord }> {
    const scope = input.tenantId ?? "platform";
    await this.transaction.raw(
      "SELECT pg_advisory_xact_lock(hashtextextended(?, 0))",
      [`${scope}:${input.key}`],
    );

    const query = this.transaction<IdempotencyRecord>("idempotency_keys")
      .where({ idempotency_key: input.key })
      .andWhere("expires_at", ">", this.transaction.fn.now())
      .orderBy("created_at", "desc");
    if (input.tenantId === null) query.whereNull("tenant_id");
    else query.andWhere("tenant_id", input.tenantId);
    const existing = await query.first();
    if (existing !== undefined) {
      if (existing.request_hash !== input.requestHash)
        throw new Error("IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST");
      return { created: false, record: existing };
    }

    const [record] = await this.transaction<IdempotencyRecord>(
      "idempotency_keys",
    )
      .insert({
        tenant_id: input.tenantId,
        idempotency_key: input.key,
        request_hash: input.requestHash,
        expires_at: input.expiresAt,
      })
      .returning("*");
    if (record === undefined)
      throw new Error("Idempotency claim returned no record");
    return { created: true, record };
  }

  public async complete(input: {
    id: string;
    responseStatus: number;
    responseBody: object;
    resourceType: string;
    resourceId: string;
  }): Promise<void> {
    const updated = await this.transaction("idempotency_keys")
      .where({ id: input.id })
      .update({
        status: "COMPLETED",
        response_status: input.responseStatus,
        response_body: input.responseBody,
        resource_type: input.resourceType,
        resource_id: input.resourceId,
        updated_at: this.transaction.fn.now(),
      });
    if (updated !== 1) throw new Error("Idempotency completion failed");
  }
}
