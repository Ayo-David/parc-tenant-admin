const probeKey = "parc-tenant-admin:readiness:probe";

interface ExpiringWriter {
  set(
    key: string,
    value: string,
    mode: "EX",
    seconds: number,
  ): Promise<unknown>;
}

/**
 * PING succeeds against a read-only replica, but the role metadata cache
 * writes, so readiness must too.
 */
export async function checkRedisWritable(redis: ExpiringWriter): Promise<void> {
  await redis.set(probeKey, String(Date.now()), "EX", 30);
}
