import { importSPKI, jwtVerify, type JWTPayload } from "jose";
import type { Knex } from "knex";
import { z } from "zod";
import { withPlatformTransaction } from "../database/transaction.js";
import { ApiError } from "../http/api-error.js";
import { AdministratorRepository } from "../repositories/administrator-repository.js";
import type {
  AdministratorAuthorizer,
  AdministratorPrincipal,
  PlatformAuthorizer,
  PlatformPrincipal,
} from "./platform-authorizer.js";

const claimsSchema = z.object({
  sub: z.string().uuid(),
  tenant_id: z.string().uuid().nullable(),
  session_id: z.string().uuid(),
  subject_type: z.literal("ADMINISTRATOR"),
  scope: z.enum(["TENANT", "PLATFORM"]),
  authorization_version: z.number().int().positive(),
  authentication_methods: z.array(z.string()).min(2),
});

type VerificationKey = Awaited<ReturnType<typeof importSPKI>>;

export class AdministratorJwtAuthorizer
  implements PlatformAuthorizer, AdministratorAuthorizer
{
  public constructor(
    private readonly database: Knex,
    private readonly issuer: string,
    private readonly audience: string,
    private readonly publicKeys: ReadonlyMap<string, VerificationKey>,
  ) {}

  public async authorize(
    accessToken: string,
    permission: string,
  ): Promise<PlatformPrincipal> {
    const principal = await this.authorizeAdministrator(
      accessToken,
      permission,
    );
    if (principal.scope !== "PLATFORM" || principal.tenantId !== null)
      throw new ApiError(
        403,
        "FORBIDDEN",
        "Platform administrator is required",
      );
    return { administratorId: principal.administratorId };
  }

  public async authorizeAdministrator(
    accessToken: string,
    permission: string,
  ): Promise<AdministratorPrincipal> {
    let payload: JWTPayload;
    try {
      const verified = await jwtVerify(
        accessToken,
        ({ kid, alg }) => {
          if (alg !== "RS256" || kid === undefined)
            throw new Error("Unsupported JWT key");
          const key = this.publicKeys.get(kid);
          if (key === undefined) throw new Error("Unknown JWT key");
          return key;
        },
        { algorithms: ["RS256"], issuer: this.issuer, audience: this.audience },
      );
      payload = verified.payload;
    } catch {
      throw new ApiError(401, "UNAUTHORIZED", "Access token is invalid");
    }
    const parsed = claimsSchema.safeParse(payload);
    if (!parsed.success || !parsed.data.authentication_methods.includes("MFA"))
      throw new ApiError(
        401,
        "UNAUTHORIZED",
        "Administrator MFA evidence is required",
      );

    return withPlatformTransaction(this.database, async (transaction) => {
      const repository = new AdministratorRepository(transaction);
      const administrator = await repository.findById(parsed.data.sub);
      if (
        administrator === undefined ||
        administrator.status !== "ACTIVE" ||
        administrator.is_platform_admin !==
          (parsed.data.scope === "PLATFORM") ||
        administrator.tenant_id !== parsed.data.tenant_id ||
        administrator.authorization_version !==
          parsed.data.authorization_version
      )
        throw new ApiError(
          401,
          "AUTHORIZATION_STALE",
          "Administrator authorization changed",
        );
      const permissions = await repository.getPermissions(administrator.id);
      if (!permissions.includes(permission))
        throw new ApiError(
          403,
          "FORBIDDEN",
          "Administrator permission is required",
        );
      return {
        administratorId: administrator.id,
        tenantId: administrator.tenant_id,
        scope: parsed.data.scope,
      };
    });
  }
}

export async function importAdministratorJwtPublicKeys(
  encodedJson: string,
): Promise<ReadonlyMap<string, VerificationKey>> {
  const encoded = JSON.parse(encodedJson) as Record<string, string>;
  const keys = new Map<string, VerificationKey>();
  for (const [kid, value] of Object.entries(encoded))
    keys.set(
      kid,
      await importSPKI(Buffer.from(value, "base64").toString("utf8"), "RS256"),
    );
  if (keys.size === 0)
    throw new Error("AUTH_JWT_PUBLIC_KEYS_JSON contains no keys");
  return keys;
}
