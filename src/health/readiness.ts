export interface ReadinessCheck {
  name: string;
  check(this: void): Promise<void>;
}

export async function checkReadiness(
  checks: readonly ReadinessCheck[],
): Promise<{
  ready: boolean;
  checks: Record<string, "UP" | "DOWN">;
}> {
  const results = await Promise.all(
    checks.map(async ({ name, check }) => {
      try {
        await check();
        return [name, "UP"] as const;
      } catch {
        return [name, "DOWN"] as const;
      }
    }),
  );
  const statuses = Object.fromEntries(results);
  return {
    ready: results.every(([, status]) => status === "UP"),
    checks: statuses,
  };
}
