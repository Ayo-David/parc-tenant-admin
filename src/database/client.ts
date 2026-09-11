import knex, { type Knex } from "knex";
import type { AppConfig } from "../config/env.js";

export function createDatabase(config: AppConfig): Knex {
  return knex({
    client: "pg",
    connection: config.DATABASE_URL,
    pool: { min: config.DATABASE_POOL_MIN, max: config.DATABASE_POOL_MAX },
  });
}

export async function checkDatabase(database: Knex): Promise<void> {
  await database.raw("SELECT 1");
}

export async function closeDatabase(database: Knex): Promise<void> {
  await database.destroy();
}
