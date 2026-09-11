import type { Knex } from "knex";
import { z } from "zod";

const tenantId = z.string().uuid();

export function withTenantTransaction<T>(
  database: Knex,
  id: string,
  work: (transaction: Knex.Transaction) => Promise<T>,
): Promise<T> {
  const validated = tenantId.parse(id);
  return database.transaction(async (transaction) => {
    await transaction.raw(
      "SELECT set_config('app.current_tenant_id', ?, true)",
      [validated],
    );
    return work(transaction);
  });
}

export function withPlatformTransaction<T>(
  database: Knex,
  work: (transaction: Knex.Transaction) => Promise<T>,
): Promise<T> {
  return database.transaction(async (transaction) => {
    await transaction.raw(
      "SELECT set_config('app.current_tenant_id', '', true)",
    );
    return work(transaction);
  });
}
