import type { Knex } from "knex";
import { loadConfig } from "./src/config/env.js";

const config = loadConfig();
const compiledMigrations = process.env.KNEX_MIGRATIONS_COMPILED === "true";

const knexConfig: Knex.Config = {
  client: "pg",
  connection: config.DATABASE_URL,
  migrations: {
    directory: compiledMigrations ? "./dist/db/migrations" : "./db/migrations",
    extension: compiledMigrations ? "js" : "ts",
    tableName: "knex_migrations",
  },
};

export default knexConfig;
