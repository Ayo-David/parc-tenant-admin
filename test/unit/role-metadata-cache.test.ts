import { jest } from "@jest/globals";
import { MemoryRoleMetadataCache } from "../../src/auth/role-metadata-cache.js";

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
