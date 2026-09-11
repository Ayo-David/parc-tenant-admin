import type { Knex } from "knex";

export interface TenantRecord {
  id: string;
  tenantCode: string;
  legalName: string;
  tradingName: string | null;
  countryCode: string;
  currencyCode: string;
  status: string;
  metadata: Record<string, unknown>;
  createdAt: Date;
  updatedAt: Date;
}

interface TenantRow {
  id: string;
  tenant_code: string;
  legal_name: string;
  trading_name: string | null;
  country_code: string;
  currency_code: string;
  status: string;
  metadata: Record<string, unknown>;
  created_at: Date;
  updated_at: Date;
}

export class TenantRepository {
  public constructor(private readonly database: Knex | Knex.Transaction) {}

  public async findById(id: string): Promise<TenantRecord | undefined> {
    const row = await this.database<TenantRow>("tenants")
      .where({ id })
      .whereNull("deleted_at")
      .first();
    return row === undefined ? undefined : mapTenant(row);
  }
}

function mapTenant(row: TenantRow): TenantRecord {
  return {
    id: row.id,
    tenantCode: row.tenant_code,
    legalName: row.legal_name,
    tradingName: row.trading_name,
    countryCode: row.country_code.trim(),
    currencyCode: row.currency_code.trim(),
    status: row.status,
    metadata: row.metadata,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}
