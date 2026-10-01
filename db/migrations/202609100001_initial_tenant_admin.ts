import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import type { Knex } from "knex";

const snapshotUrl = new URL("../schema/current.sql", import.meta.url);
const approvedExistingBaselineHash =
  "f43e534250c7ca3704fe45b2ff9397ef1d3bb6dbe3e86b3167e6544dee3d03eb";
const canonicalSnapshotHash =
  "1f8ff335a94bbd70247d394d4645f27a29332436df88ad9b0b37f7e49663a9c8";

export const config = { transaction: false };

export async function up(knex: Knex): Promise<void> {
  const exists = await knex.schema.hasTable("tenants");
  if (exists) {
    const supplied = process.env.APPROVED_EXISTING_BASELINE_SHA256;
    if (supplied !== approvedExistingBaselineHash) {
      throw new Error(
        "Existing Tenant Admin schema requires the explicitly approved baseline SHA-256",
      );
    }
    return;
  }

  // The regenerated schema snapshot contains grants to these cluster roles.
  await knex.raw(`
    DO $roles$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_service') THEN
        CREATE ROLE parc_service NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_readonly') THEN
        CREATE ROLE parc_readonly NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_admin') THEN
        CREATE ROLE parc_admin NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_runtime') THEN
        CREATE ROLE parc_tenant_admin_runtime NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_platform') THEN
        CREATE ROLE parc_tenant_admin_platform NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_worker') THEN
        CREATE ROLE parc_tenant_admin_worker NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'parc_tenant_admin_readonly') THEN
        CREATE ROLE parc_tenant_admin_readonly NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
      END IF;
    END
    $roles$;
  `);

  const sql = await readFile(fileURLToPath(snapshotUrl), "utf8");
  const actualHash = createHash("sha256").update(sql).digest("hex");
  if (actualHash !== canonicalSnapshotHash) {
    throw new Error(
      `Tenant Admin schema snapshot hash mismatch: ${actualHash}`,
    );
  }
  await knex.raw(sql);
  // pg_dump's session settings (row_security = off, check_function_bodies = false, an
  // empty search_path, ...) persist on this pooled connection; reset them before later migrations.
  await knex.raw("RESET ALL");
  // Restore search_path for Knex's migration bookkeeping.
  await knex.raw("SET search_path TO public");
}

export function down(): Promise<never> {
  return Promise.reject(new Error("The Tenant Admin baseline is forward-only"));
}
