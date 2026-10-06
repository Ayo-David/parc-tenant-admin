import { createServer } from "node:http";
import { createApp } from "./app.js";
import { UnconfiguredAdministratorAuthorizer } from "./auth/platform-authorizer.js";
import { importAdministratorJwtPublicKeys } from "./auth/auth-public-keys.js";
import { AdministratorTokenAuthorizer } from "./auth/administrator-token-authorizer.js";
import { createParcAuth } from "./security/parc-service-auth.js";
import {
  MemoryRoleMetadataCache,
  RedisRoleMetadataCache,
} from "./auth/role-metadata-cache.js";
import { createClient } from "redis";
import { loadConfig } from "./config/env.js";
import {
  checkDatabase,
  closeDatabase,
  createDatabase,
} from "./database/client.js";
import { createLogger } from "./utils/logger.js";
import { TenantLifecycleService } from "./services/tenant-lifecycle-service.js";
import { AdministratorIdentityService } from "./services/administrator-identity-service.js";
import { ApprovalService } from "./services/approval-service.js";
import { ProviderSelectionService } from "./services/provider-selection-service.js";
import { ConfigurationService } from "./services/configuration-service.js";
import { MobileBootstrapService } from "./services/mobile-bootstrap-service.js";
import { CustomerSupportService } from "./services/customer-support-service.js";
import { OnboardingReferenceDataService } from "./services/onboarding-reference-data-service.js";
import { ConsentDocumentService } from "./services/consent-document-service.js";

const config = loadConfig();
const logger = createLogger(config);
const database = createDatabase(config);
const redis =
  config.REDIS_URL === undefined
    ? undefined
    : createClient({ url: config.REDIS_URL });
if (redis !== undefined) {
  redis.on("error", (error) => logger.error({ err: error }, "Redis error"));
  await redis.connect();
}
const roleCache =
  redis === undefined
    ? new MemoryRoleMetadataCache(config.AUTHORIZATION_CACHE_TTL_SECONDS)
    : new RedisRoleMetadataCache(redis, config.AUTHORIZATION_CACHE_TTL_SECONDS);
const administratorIdentity = new AdministratorIdentityService(
  database,
  config.IDEMPOTENCY_HASH_SECRET,
  roleCache,
);
const approvalService = new ApprovalService(database);
const consentDocumentService = new ConsentDocumentService(
  database,
  approvalService,
);
const configurationService = new ConfigurationService(
  database,
  approvalService,
);
const allowedServices = new Set(
  config.APPROVAL_CONSUMER_SERVICES.split(",")
    .map((value) => value.trim())
    .filter(Boolean),
);
// Every inbound internal and console call carries an Auth-issued token for
// this audience; platform-level (tenantless) tokens are accepted here only.
const staticKeys =
  config.AUTH_JWT_PUBLIC_KEYS_JSON === undefined
    ? undefined
    : await importAdministratorJwtPublicKeys(config.AUTH_JWT_PUBLIC_KEYS_JSON);
const serviceAuth =
  staticKeys === undefined && config.AUTH_JWKS_URL === undefined
    ? undefined
    : createParcAuth({
        issuer: config.AUTH_JWT_ISSUER,
        audience: config.SERVICE_NAME,
        allowPlatformTenant: true,
        ...(staticKeys === undefined
          ? { jwksUrl: config.AUTH_JWKS_URL ?? "" }
          : {
              keys: ({ kid }) => {
                const key = kid === undefined ? undefined : staticKeys.get(kid);
                if (key === undefined) throw new Error("Unknown JWT key");
                return key;
              },
            }),
      });
const platformAuthorizer =
  serviceAuth === undefined
    ? new UnconfiguredAdministratorAuthorizer()
    : new AdministratorTokenAuthorizer(database, serviceAuth);
const app = createApp({
  config,
  logger,
  database,
  ...(serviceAuth === undefined ? {} : { serviceAuth }),
  readinessChecks: [
    { name: "database", check: () => checkDatabase(database) },
    ...(redis === undefined
      ? []
      : [{ name: "redis", check: async () => void (await redis.ping()) }]),
  ],
  tenantLifecycle: {
    service: new TenantLifecycleService(database),
    authorizer: platformAuthorizer,
  },
  administratorIdentity: {
    service: administratorIdentity,
  },
  approvals: {
    service: approvalService,
    authorizer: platformAuthorizer,
    allowedServices,
  },
  providerSelection: {
    service: new ProviderSelectionService(database, approvalService),
    authorizer: platformAuthorizer,
    allowedServices,
  },
  configuration: {
    service: configurationService,
    authorizer: platformAuthorizer,
    allowedServices,
  },
  mobileBootstrap: {
    service: new MobileBootstrapService(database, configurationService),
    allowedServices: new Set(["parc-mobile-bff"]),
  },
  customerSupport: {
    service: new CustomerSupportService(database),
    allowedServices: new Set(["parc-mobile-bff"]),
  },
  onboardingReferenceData: {
    service: new OnboardingReferenceDataService(
      database,
      consentDocumentService,
    ),
    allowedServices: new Set(["parc-mobile-bff"]),
  },
  consentDocuments: {
    service: consentDocumentService,
    authorizer: platformAuthorizer,
    allowedServices,
  },
});
const server = createServer(app);

server.listen(config.PORT, config.HOST, () => {
  logger.info(
    { host: config.HOST, port: config.PORT },
    "Tenant Admin service listening",
  );
});

let shuttingDown = false;
function shutdown(signal: NodeJS.Signals): void {
  if (shuttingDown) return;
  shuttingDown = true;
  logger.info({ signal }, "Graceful shutdown started");
  const timer = setTimeout(() => {
    logger.error("Graceful shutdown timed out");
    process.exitCode = 1;
    server.closeAllConnections();
  }, config.SHUTDOWN_TIMEOUT_MS);
  timer.unref();
  server.close((error) => {
    clearTimeout(timer);
    if (error) {
      logger.error({ err: error }, "Server close failed");
      process.exitCode = 1;
    }
    void closeDatabase(database).catch((databaseError: unknown) => {
      logger.error({ err: databaseError }, "Database close failed");
      process.exitCode = 1;
    });
    if (redis !== undefined)
      void redis.close().catch((redisError: unknown) => {
        logger.error({ err: redisError }, "Redis close failed");
        process.exitCode = 1;
      });
  });
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
