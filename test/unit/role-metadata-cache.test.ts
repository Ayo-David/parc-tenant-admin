import { jest } from "@jest/globals";
import {
  MemoryRoleMetadataCache,
  RedisRoleMetadataCache,
} from "../../src/auth/role-metadata-cache.js";

describe("role metadata cache", () => {
  afterEach(() => jest.useRealTimers());

  it("keys non-sensitive role metadata by authorization version and expires quickly", async () => {
    jest.useFakeTimers().setSystemTime(new Date("2026-09-10T00:00:00Z"));
    const cache = new MemoryRoleMetadataCache(30);
    await cache.set("administrator", 1, ["PLATFORM_OPERATOR"]);
    await expect(cache.get("administrator", 1)).resolves.toEqual([
      "PLATFORM_OPERATOR",
    ]);
    await expect(cache.get("administrator", 2)).resolves.toBeUndefined();
    jest.advanceTimersByTime(30_001);
    await expect(cache.get("administrator", 1)).resolves.toBeUndefined();
  });
});

describe("redis role metadata cache", () => {
  it("stores roles with an expiry and reads them back by authorization version", async () => {
    const store = new Map<string, string>();
    const set = jest.fn((key: string, value: string) => {
      store.set(key, value);
      return Promise.resolve("OK" as const);
    });
    const get = jest.fn((key: string) =>
      Promise.resolve(store.get(key) ?? null),
    );
    const cache = new RedisRoleMetadataCache({ get, set }, 30);
    await cache.set("administrator", 1, ["PLATFORM_OPERATOR"]);
    expect(set).toHaveBeenCalledWith(
      "tenant-admin:role-metadata:administrator:1",
      '["PLATFORM_OPERATOR"]',
      "EX",
      30,
    );
    await expect(cache.get("administrator", 1)).resolves.toEqual([
      "PLATFORM_OPERATOR",
    ]);
    await expect(cache.get("administrator", 2)).resolves.toBeUndefined();
  });
});
