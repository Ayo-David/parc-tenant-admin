import { loadConfig } from "../../src/config/env.js";

describe("environment configuration", () => {
  it("loads safe development defaults", () => {
    expect(loadConfig({})).toMatchObject({
      PORT: 3002,
      SERVICE_NAME: "parc-tenant-admin",
    });
  });

  it("rejects the development service token in production", () => {
    expect(() => loadConfig({ NODE_ENV: "production" })).toThrow(
      "Production requires",
    );
  });
});
