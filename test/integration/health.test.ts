import pino from "pino";
import request from "supertest";
import { createApp } from "../../src/app.js";
import { loadConfig } from "../../src/config/env.js";

const logger = pino({ enabled: false });

describe("service health", () => {
  it("reports liveness", async () => {
    const response = await request(
      createApp({ config: loadConfig({ NODE_ENV: "test" }), logger }),
    ).get("/health");
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: "UP",
      service: "parc-tenant-admin",
    });
  });

  it("reports failed dependencies as not ready", async () => {
    const response = await request(
      createApp({
        config: loadConfig({ NODE_ENV: "test" }),
        logger,
        readinessChecks: [
          {
            name: "postgres",
            check: async () => Promise.reject(new Error("down")),
          },
        ],
      }),
    ).get("/ready");
    expect(response.status).toBe(503);
    expect(response.body).toMatchObject({ status: "DOWN", ready: false });
  });
});
