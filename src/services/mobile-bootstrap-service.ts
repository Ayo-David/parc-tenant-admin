import type { Knex } from "knex";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import type { ConfigurationService } from "./configuration-service.js";

interface ResolvedConfiguration {
  configurations: Array<{ key: string; value: unknown }>;
}

export class MobileBootstrapService {
  public constructor(
    private readonly database: Knex,
    private readonly configurations: ConfigurationService,
  ) {}

  public async resolve(input: {
    tenantSlug: string;
    appVersion: string;
    platform: "android" | "ios";
  }): Promise<{
    tenant_id: string;
    minimum_supported_version: string;
    maintenance: boolean;
    features: Record<string, boolean>;
  }> {
    const tenant = await withPlatformTransaction(this.database, (tx) =>
      tx("tenants")
        .whereRaw("lower(tenant_code) = ?", [input.tenantSlug.toLowerCase()])
        .where({ status: "ACTIVE" })
        .whereNull("deleted_at")
        .first<{ id: string; tier_id: string | null }>("id", "tier_id"),
    );
    if (!tenant)
      throw new ApiError(
        404,
        "TENANT_NOT_FOUND",
        "Active tenant was not found",
      );
    const minimumKey = `mobile.minimum_supported_version.${input.platform}`;
    const resolved = (await this.configurations.resolve(tenant.id, [
      minimumKey,
      "mobile.maintenance",
    ])) as ResolvedConfiguration;
    const values = new Map(
      resolved.configurations.map((item) => [item.key, item.value]),
    );
    const minimum = stringValue(values.get(minimumKey), "1.0.0");
    if (compareVersions(input.appVersion, minimum) < 0)
      throw new ApiError(
        426,
        "APP_UPGRADE_REQUIRED",
        "Mobile application upgrade is required",
      );
    const features = await this.features(tenant.id, tenant.tier_id);
    return {
      tenant_id: tenant.id,
      minimum_supported_version: minimum,
      maintenance: booleanValue(values.get("mobile.maintenance"), false),
      features,
    };
  }

  private features(
    tenantId: string,
    tierId: string | null,
  ): Promise<Record<string, boolean>> {
    return withPlatformTransaction(this.database, async (tx) => {
      const result = await tx.raw<{
        rows: Array<{ code: string; enabled: boolean }>;
      }>(
        `SELECT f.code,
                COALESCE(o.enabled, tf.enabled,
                  CASE WHEN jsonb_typeof(f.default_value) = 'boolean'
                       THEN (f.default_value #>> '{}')::boolean
                       ELSE false END) AS enabled
           FROM features f
           LEFT JOIN tier_features tf
             ON tf.feature_id = f.id AND tf.tier_id = ?
           LEFT JOIN LATERAL (
             SELECT x.enabled
               FROM tenant_feature_overrides x
              WHERE x.tenant_id = ?
                AND x.feature_id = f.id
                AND x.deleted_at IS NULL
                AND x.effective_from <= now()
                AND (x.effective_until IS NULL OR x.effective_until > now())
              ORDER BY x.effective_from DESC, x.created_at DESC
              LIMIT 1
           ) o ON true
          WHERE f.status = 'ACTIVE' AND f.deleted_at IS NULL
          ORDER BY f.code`,
        [tierId, tenantId],
      );
      return Object.fromEntries(
        result.rows.map((row) => [row.code, row.enabled]),
      );
    });
  }
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value.length > 0 ? value : fallback;
}
function booleanValue(value: unknown, fallback: boolean): boolean {
  return typeof value === "boolean" ? value : fallback;
}
function compareVersions(left: string, right: string): number {
  const a = versionParts(left);
  const b = versionParts(right);
  for (let index = 0; index < Math.max(a.length, b.length); index += 1) {
    const difference = (a[index] ?? 0) - (b[index] ?? 0);
    if (difference !== 0) return difference;
  }
  return 0;
}
function versionParts(value: string): number[] {
  if (!/^\d+(\.\d+){0,3}$/.test(value))
    throw new ApiError(422, "APP_VERSION_INVALID", "App version is invalid");
  return value.split(".").map(Number);
}
