import { randomUUID } from "node:crypto";
import knex, { type Knex } from "knex";
import { withTenantTransaction } from "../../src/database/transaction.js";
import { InboxRepository } from "../../src/repositories/inbox-repository.js";
import { TenantRepository } from "../../src/repositories/tenant-repository.js";

const databaseUrl = process.env.TEST_DATABASE_URL;
const describeDatabase = databaseUrl === undefined ? describe.skip : describe;

describeDatabase("Tenant Admin persistence foundation", () => {
  let database: Knex;
  const firstTenantId = randomUUID();
  const secondTenantId = randomUUID();

  beforeAll(async () => {
    database = knex({ client: "pg", connection: databaseUrl! });
    await database("tenants").insert([
      {
        id: firstTenantId,
        tenant_code: `T${firstTenantId.replaceAll("-", "").slice(0, 12)}`,
        legal_name: "First test tenant",
        tenant_type: "MFB",
      },
      {
        id: secondTenantId,
        tenant_code: `T${secondTenantId.replaceAll("-", "").slice(0, 12)}`,
        legal_name: "Second test tenant",
        tenant_type: "MFB",
      },
    ]);
  });

  afterAll(async () => {
    await database("inbox_events")
      .whereIn("tenant_id", [firstTenantId, secondTenantId])
      .delete();
    await database("tenants")
      .whereIn("id", [firstTenantId, secondTenantId])
      .delete();
    await database.destroy();
  });

  it("forces every enabled RLS table and creates non-bypass application roles", async () => {
    const result = await database.raw<{ rows: Array<{ missing: string }> }>(`
      SELECT count(*)::text AS missing
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relrowsecurity AND NOT c.relforcerowsecurity
    `);
    expect(result.rows[0]?.missing).toBe("0");

    const roles = await database("pg_roles")
      .select("rolname", "rolsuper", "rolbypassrls", "rolcanlogin")
      .whereIn("rolname", [
        "parc_tenant_admin_runtime",
        "parc_tenant_admin_platform",
        "parc_tenant_admin_worker",
        "parc_tenant_admin_readonly",
      ]);
    expect(roles).toHaveLength(4);
    expect(roles).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          rolsuper: false,
          rolbypassrls: false,
          rolcanlogin: false,
        }),
      ]),
    );
  });

  it("isolates tenant repositories even when a caller sets the former elevation flag", async () => {
    await database.transaction(async (transaction) => {
      await transaction.raw("SET LOCAL ROLE parc_tenant_admin_runtime");
      await transaction.raw(
        "SELECT set_config('app.is_platform_admin', 'true', true)",
      );
      const visible = await withTenantTransaction(
        transaction,
        firstTenantId,
        async (tenantTx) => tenantTx("tenants").select("id"),
      );
      expect(visible).toEqual([{ id: firstTenantId }]);

      const tenant = await withTenantTransaction(
        transaction,
        firstTenantId,
        async (tenantTx) =>
          new TenantRepository(tenantTx).findById(firstTenantId),
      );
      expect(tenant?.legalName).toBe("First test tenant");
    });
  });

  it("allows only the dedicated platform role to see every tenant", async () => {
    await database.transaction(async (transaction) => {
      await transaction.raw("SET LOCAL ROLE parc_tenant_admin_platform");
      const rows = await transaction("tenants")
        .select("id")
        .whereIn("id", [firstTenantId, secondTenantId]);
      expect(rows).toHaveLength(2);
    });
  });

  it("prevents the tenant runtime role from mutating platform catalog tables", async () => {
    await expect(
      database.transaction(async (transaction) => {
        await transaction.raw("SET LOCAL ROLE parc_tenant_admin_runtime");
        await transaction("admin_permissions").insert({
          resource: "test",
          action: "READ",
          code: `test.${randomUUID()}`,
        });
      }),
    ).rejects.toThrow(/permission denied/i);
  });

  it("deduplicates inbox delivery within the tenant boundary", async () => {
    const eventId = randomUUID();
    await database.transaction(async (transaction) => {
      await transaction.raw("SET LOCAL ROLE parc_tenant_admin_runtime");
      await withTenantTransaction(
        transaction,
        firstTenantId,
        async (tenantTx) => {
          const repository = new InboxRepository(tenantTx);
          const event = {
            eventId,
            tenantId: firstTenantId,
            sourceService: "parc-auth-customer",
            eventType: "customer.registered.v1",
            eventVersion: 1,
            payload: { customer_id: randomUUID() },
          };
          const first = await repository.receive(event);
          const duplicate = await repository.receive(event);
          expect(first.duplicate).toBe(false);
          expect(duplicate).toEqual({ id: first.id, duplicate: true });
          expect(await repository.markProcessed(first.id)).toBe(true);
        },
      );
    });
  });
});
