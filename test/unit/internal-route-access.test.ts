import { randomUUID } from "node:crypto";
import { jest } from "@jest/globals";
import pino from "pino";
import request from "supertest";
import { createApp } from "../../src/app.js";
import { loadConfig } from "../../src/config/env.js";
import type { CustomerSupportService } from "../../src/services/customer-support-service.js";
import type { MobileBootstrapService } from "../../src/services/mobile-bootstrap-service.js";
import { serviceTokens } from "../support/service-tokens.js";

const tenantId = "11111111-1111-4111-8111-111111111111";
const customerId = "22222222-2222-4222-8222-222222222222";

describe("Tenant Admin internal route access", () => {
  let tokens: Awaited<ReturnType<typeof serviceTokens>>;
  let app: ReturnType<typeof createApp>;
  const resolve = jest.fn(() => Promise.resolve({ tenant_id: tenantId }));
  const listTickets = jest.fn(() => Promise.resolve([]));

  beforeAll(async () => {
    tokens = await serviceTokens();
    app = createApp({
      config: loadConfig({ NODE_ENV: "test" }),
      logger: pino({ enabled: false }),
      serviceAuth: tokens.serviceAuth,
      mobileBootstrap: {
        service: { resolve } as unknown as MobileBootstrapService,
        allowedServices: new Set(["parc-mobile-bff"]),
      },
      customerSupport: {
        service: { listTickets } as unknown as CustomerSupportService,
        allowedServices: new Set(["parc-mobile-bff"]),
      },
    });
  });

  const bootstrap = (token?: string) => {
    const call = request(app).get(
      "/internal/v1/mobile/bootstrap?tenant_slug=acme&app_version=1.0.0&platform=ios",
    );
    return token ? call.set("authorization", `Bearer ${token}`) : call;
  };

  it("serves pre-login bootstrap to the Mobile BFF's platform service token", async () => {
    await bootstrap(
      await tokens.service(
        "parc-mobile-bff",
        "tenant.mobile-bootstrap.read",
        null,
      ),
    ).expect(200);
    expect(resolve).toHaveBeenCalledTimes(1);
  });

  it("rejects missing tokens, other callers, wrong scopes and legacy secrets", async () => {
    await bootstrap().expect(401);
    await request(app)
      .get(
        "/internal/v1/mobile/bootstrap?tenant_slug=acme&app_version=1.0.0&platform=ios",
      )
      .set("x-internal-service-token", "development-service-token-change-me")
      .set("x-calling-service", "parc-mobile-bff")
      .expect(401);
    await bootstrap(
      await tokens.service(
        "parc-payment",
        "tenant.mobile-bootstrap.read",
        null,
      ),
    ).expect(403);
    await bootstrap(
      await tokens.service(
        "parc-mobile-bff",
        "tenant.onboarding-reference.read",
        null,
      ),
    ).expect(403);
    expect(resolve).toHaveBeenCalledTimes(1);
  });

  it("limits customer support to the delegated customer's own tickets", async () => {
    const support = (id: string, token: string) =>
      request(app)
        .get(`/internal/v1/customers/${id}/support/tickets`)
        .set("authorization", `Bearer ${token}`)
        .set("x-tenant-id", tenantId);
    const scope = "tenant.customer-support.read";
    await support(
      customerId,
      await tokens.customer(customerId, tenantId, scope),
    ).expect(200);
    await support(
      randomUUID(),
      await tokens.customer(customerId, tenantId, scope),
    ).expect(403);
    await support(
      customerId,
      await tokens.service("parc-mobile-bff", scope, tenantId),
    ).expect(403);
    await support(
      customerId,
      await tokens.administrator(customerId, tenantId, scope),
    ).expect(403);
    expect(listTickets).toHaveBeenCalledTimes(1);
  });
});
