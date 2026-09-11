import type { RedisClientType } from "redis";

export interface RoleMetadataCache {
  get(
    administratorId: string,
    authorizationVersion: number,
  ): Promise<string[] | undefined>;
  set(
    administratorId: string,
    authorizationVersion: number,
    roles: readonly string[],
  ): Promise<void>;
}

export class MemoryRoleMetadataCache implements RoleMetadataCache {
  private readonly values = new Map<
    string,
    { roles: string[]; expiresAt: number }
  >();
  public constructor(private readonly ttlSeconds: number) {}

  public get(
    administratorId: string,
    authorizationVersion: number,
  ): Promise<string[] | undefined> {
    const value = this.values.get(key(administratorId, authorizationVersion));
    if (value === undefined || value.expiresAt <= Date.now())
      return Promise.resolve(undefined);
    return Promise.resolve([...value.roles]);
  }

  public set(
    administratorId: string,
    authorizationVersion: number,
    roles: readonly string[],
  ): Promise<void> {
    this.values.set(key(administratorId, authorizationVersion), {
      roles: [...roles],
      expiresAt: Date.now() + this.ttlSeconds * 1000,
    });
    return Promise.resolve();
  }
}

export class RedisRoleMetadataCache implements RoleMetadataCache {
  public constructor(
    private readonly redis: RedisClientType,
    private readonly ttlSeconds: number,
  ) {}

  public async get(
    administratorId: string,
    authorizationVersion: number,
  ): Promise<string[] | undefined> {
    const value = await this.redis.get(
      key(administratorId, authorizationVersion),
    );
    return value === null ? undefined : (JSON.parse(value) as string[]);
  }

  public async set(
    administratorId: string,
    authorizationVersion: number,
    roles: readonly string[],
  ): Promise<void> {
    await this.redis.set(
      key(administratorId, authorizationVersion),
      JSON.stringify(roles),
      {
        expiration: { type: "EX", value: this.ttlSeconds },
      },
    );
  }
}

function key(administratorId: string, authorizationVersion: number): string {
  return `tenant-admin:role-metadata:${administratorId}:${authorizationVersion}`;
}
