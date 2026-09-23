import { createServer } from "node:http";
import { createApp } from "./app.js";
import { UnconfiguredAdministratorAuthorizer } from "./auth/platform-authorizer.js";
import {
  AdministratorJwtAuthorizer,
  importAdministratorJwtPublicKeys,
} from "./auth/administrator-jwt-authorizer.js";
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
  config.INTERNAL_SERVICE_TOKEN,
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
const platformAuthorizer =
  config.AUTH_JWT_PUBLIC_KEYS_JSON === undefined
    ? new UnconfiguredAdministratorAuthorizer()
    : new AdministratorJwtAuthorizer(
        database,
        config.AUTH_JWT_ISSUER,
        config.AUTH_JWT_AUDIENCE,
        await importAdministratorJwtPublicKeys(
          config.AUTH_JWT_PUBLIC_KEYS_JSON,
        ),
      );
const app = createApp({
  config,
  logger,
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
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
  },
  approvals: {
    service: approvalService,
    authorizer: platformAuthorizer,
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices,
  },
  providerSelection: {
    service: new ProviderSelectionService(database, approvalService),
    authorizer: platformAuthorizer,
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices,
  },
  configuration: {
    service: configurationService,
    authorizer: platformAuthorizer,
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices,
  },
  mobileBootstrap: {
    service: new MobileBootstrapService(database, configurationService),
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices: new Set(["parc-mobile-bff"]),
  },
  customerSupport: {
    service: new CustomerSupportService(database),
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices,
  },
  onboardingReferenceData: {
    service: new OnboardingReferenceDataService(
      database,
      consentDocumentService,
    ),
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
    allowedServices: new Set(["parc-mobile-bff"]),
  },
  consentDocuments: {
    service: consentDocumentService,
    authorizer: platformAuthorizer,
    serviceToken: config.INTERNAL_SERVICE_TOKEN,
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
