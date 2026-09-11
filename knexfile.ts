import type { Knex } from "knex";
import { loadConfig } from "./src/config/env.js";

const config = loadConfig();

const knexConfig: Knex.Config = {
  client: "pg",
  connection: config.DATABASE_URL,
  migrations: {
    directory: "./db/migrations",
    extension: "ts",
    tableName: "knex_migrations",
  },
};

export default knexConfig;
