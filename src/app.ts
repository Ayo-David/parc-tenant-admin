import { randomUUID } from "node:crypto";
import express, { type Express, type RequestHandler } from "express";
import helmet from "helmet";
import { pinoHttp } from "pino-http";
import type { Logger } from "pino";
import type {
  AdministratorAuthorizer,
  PlatformAuthorizer,
} from "./auth/platform-authorizer.js";
import type { AppConfig } from "./config/env.js";
import { checkReadiness, type ReadinessCheck } from "./health/readiness.js";
import { ApiError } from "./http/api-error.js";
import { createTenantLifecycleRouter } from "./http/tenant-lifecycle-router.js";
import { createInternalAdministratorRouter } from "./http/internal-administrator-router.js";
import type { AdministratorIdentityService } from "./services/administrator-identity-service.js";
import type { TenantLifecycleService } from "./services/tenant-lifecycle-service.js";
import type { ApprovalService } from "./services/approval-service.js";
import { createApprovalRouter } from "./http/approval-router.js";
import { createProviderSelectionRouter } from "./http/provider-selection-router.js";
import type { ProviderSelectionService } from "./services/provider-selection-service.js";
import { createConfigurationRouter } from "./http/configuration-router.js";
import type { ConfigurationService } from "./services/configuration-service.js";
import { createMobileBootstrapRouter } from "./http/mobile-bootstrap-router.js";
import type { MobileBootstrapService } from "./services/mobile-bootstrap-service.js";
import { createCustomerSupportRouter } from "./http/customer-support-router.js";
import type { CustomerSupportService } from "./services/customer-support-service.js";
import { createOnboardingReferenceDataRouter } from "./http/onboarding-reference-data-router.js";
import type { OnboardingReferenceDataService } from "./services/onboarding-reference-data-service.js";
import { createConsentDocumentRouter } from "./http/consent-document-router.js";
import type { ConsentDocumentService } from "./services/consent-document-service.js";

export function createApp(input: {
  config: AppConfig;
  logger: Logger;
  readinessChecks?: readonly ReadinessCheck[];
  tenantLifecycle?: {
    service: TenantLifecycleService;
    authorizer: PlatformAuthorizer;
  };
  administratorIdentity?: {
    service: AdministratorIdentityService;
    serviceToken: string;
  };
  approvals?: {
    service: ApprovalService;
    authorizer: AdministratorAuthorizer;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  providerSelection?: {
    service: ProviderSelectionService;
    authorizer: AdministratorAuthorizer;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  configuration?: {
    service: ConfigurationService;
    authorizer: AdministratorAuthorizer;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  mobileBootstrap?: {
    service: MobileBootstrapService;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  customerSupport?: {
    service: CustomerSupportService;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  onboardingReferenceData?: {
    service: OnboardingReferenceDataService;
    serviceToken: string;
    allowedServices: ReadonlySet<string>;
  };
  consentDocuments?: {
    service: ConsentDocumentService;
    authorizer: AdministratorAuthorizer;
    serviceToken: string;
  };
}): Express {
  const app = express();
  app.disable("x-powered-by");
  app.use(helmet());
  app.use(express.json({ limit: "256kb" }));
  app.use(
    pinoHttp({
      logger: input.logger,
      genReqId(request, response) {
        const supplied = request.headers["x-request-id"];
        const id =
          typeof supplied === "string" && supplied.length <= 150
            ? supplied
            : randomUUID();
        response.setHeader("x-request-id", id);
        return id;
      },
    }) as RequestHandler,
  );
  app.get("/health", (_request, response) => {
    response.status(200).json({
      status: "UP",
      service: input.config.SERVICE_NAME,
      version: input.config.SERVICE_VERSION,
    });
  });
  app.get("/ready", async (_request, response) => {
    const result = await checkReadiness(input.readinessChecks ?? []);
    response.status(result.ready ? 200 : 503).json({
      status: result.ready ? "UP" : "DOWN",
      ...result,
    });
  });
  if (input.tenantLifecycle !== undefined)
    app.use(createTenantLifecycleRouter(input.tenantLifecycle));
  if (input.administratorIdentity !== undefined)
    app.use(createInternalAdministratorRouter(input.administratorIdentity));
  if (input.approvals !== undefined)
    app.use(createApprovalRouter(input.approvals));
  if (input.providerSelection !== undefined)
    app.use(createProviderSelectionRouter(input.providerSelection));
  if (input.configuration !== undefined)
    app.use(createConfigurationRouter(input.configuration));
  if (input.mobileBootstrap !== undefined)
    app.use(createMobileBootstrapRouter(input.mobileBootstrap));
  if (input.customerSupport !== undefined)
    app.use(createCustomerSupportRouter(input.customerSupport));
  if (input.onboardingReferenceData !== undefined)
    app.use(createOnboardingReferenceDataRouter(input.onboardingReferenceData));
  if (input.consentDocuments !== undefined)
    app.use(createConsentDocumentRouter(input.consentDocuments));
  app.use((_request, response) => {
    response
      .status(404)
      .json({ code: "NOT_FOUND", message: "Resource not found" });
  });
  app.use(
    (
      error: unknown,
      _request: express.Request,
      response: express.Response,
      _next: express.NextFunction,
    ) => {
      void _next;
      const apiError =
        error instanceof ApiError
          ? error
          : new ApiError(500, "INTERNAL_ERROR", "An internal error occurred");
      if (!(error instanceof ApiError))
        input.logger.error({ err: error }, "Unhandled request error");
      response.status(apiError.status).json({
        code: apiError.code,
        message: apiError.message,
        ...(apiError.details === undefined
          ? {}
          : { details: apiError.details }),
      });
    },
  );
  return app;
}
