import { z } from "zod";

const schema = z
  .object({
    NODE_ENV: z
      .enum(["development", "test", "production"])
      .default("development"),
    HOST: z.string().min(1).default("0.0.0.0"),
    PORT: z.coerce.number().int().min(1).max(65_535).default(3002),
    LOG_LEVEL: z
      .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
      .default("info"),
    SERVICE_NAME: z.string().min(1).default("parc-tenant-admin"),
    SERVICE_VERSION: z.string().min(1).default("0.1.0"),
    SHUTDOWN_TIMEOUT_MS: z.coerce.number().int().positive().default(10_000),
    DATABASE_URL: z.string().min(1).default("postgresql:///parc_tenant_admin"),
    DATABASE_POOL_MIN: z.coerce.number().int().min(0).default(0),
    DATABASE_POOL_MAX: z.coerce.number().int().positive().default(10),
    INTERNAL_SERVICE_TOKEN: z
      .string()
      .min(32)
      .default("development-service-token-change-me"),
    AUTH_JWT_ISSUER: z.string().url().default("https://auth.parc.invalid"),
    AUTH_JWT_AUDIENCE: z.string().min(1).default("tenant-admin"),
    AUTH_JWT_PUBLIC_KEYS_JSON: z.string().min(2).optional(),
    AUTHORIZATION_CACHE_TTL_SECONDS: z.coerce
      .number()
      .int()
      .min(1)
      .max(60)
      .default(30),
    REDIS_URL: z.string().url().optional(),
    APPROVAL_CONSUMER_SERVICES: z
      .string()
      .min(1)
      .default(
        "parc-auth-customer,parc-tenant-admin,parc-ledger,parc-payment,parc-lending,parc-savings",
      ),
  })
  .refine(
    ({ DATABASE_POOL_MIN, DATABASE_POOL_MAX }) =>
      DATABASE_POOL_MIN <= DATABASE_POOL_MAX,
    { message: "DATABASE_POOL_MIN must not exceed DATABASE_POOL_MAX" },
  )
  .refine(
    ({ NODE_ENV, INTERNAL_SERVICE_TOKEN }) =>
      NODE_ENV !== "production" ||
      INTERNAL_SERVICE_TOKEN !== "development-service-token-change-me",
    { message: "Production requires INTERNAL_SERVICE_TOKEN" },
  )
  .refine(
    ({ NODE_ENV, AUTH_JWT_PUBLIC_KEYS_JSON }) =>
      NODE_ENV !== "production" || AUTH_JWT_PUBLIC_KEYS_JSON !== undefined,
    { message: "Production requires AUTH_JWT_PUBLIC_KEYS_JSON" },
  );

export type AppConfig = z.infer<typeof schema>;
export function loadConfig(
  environment: NodeJS.ProcessEnv = process.env,
): AppConfig {
  return schema.parse(environment);
}
