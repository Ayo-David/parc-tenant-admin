import type { Knex } from "knex";
import { loadDatabaseConfig } from "./src/config/env.js";

const config = loadDatabaseConfig();
const compiledMigrations = process.env.KNEX_MIGRATIONS_COMPILED === "true";

const knexConfig: Knex.Config = {
  client: "pg",
  connection: config.DATABASE_URL,
  migrations: {
    // The knex CLI changes into the knexfile's directory (dist/ when compiled).
    directory: "./db/migrations",
    extension: compiledMigrations ? "js" : "ts",
    // Only load runnable files; the build also emits .d.ts declarations here.
    loadExtensions: compiledMigrations ? [".js"] : [".ts"],
    tableName: "knex_migrations",
  },
};

export default knexConfig;
