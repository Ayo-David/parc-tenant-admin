import { randomUUID } from "node:crypto";
import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT } from "jose";
import {
  createParcAuth,
  type ParcAuth,
} from "../../src/security/parc-service-auth.js";

const issuer = "https://auth.parc.invalid";

/** Signs Auth-shaped tokens for the parc-tenant-admin audience in tests. */
export async function serviceTokens(): Promise<{
  serviceAuth: ParcAuth;
  service(
    client: string,
    scope: string,
    tenantId: string | null,
  ): Promise<string>;
  administrator(
    administratorId: string,
    tenantId: string | null,
    scope?: string,
  ): Promise<string>;
  customer(
    customerId: string,
    tenantId: string,
    scope: string,
  ): Promise<string>;
}> {
  const keys = await generateKeyPair("RS256");
  const jwks = createLocalJWKSet({
    keys: [{ ...(await exportJWK(keys.publicKey)), kid: "k1", alg: "RS256" }],
  });
  const sign = (claims: Record<string, unknown>) =>
    new SignJWT(claims)
      .setProtectedHeader({ alg: "RS256", kid: "k1" })
      .setIssuer(issuer)
      .setAudience("parc-tenant-admin")
      .setJti(randomUUID())
      .setIssuedAt()
      .setExpirationTime("5m")
      .sign(keys.privateKey);
  return {
    serviceAuth: createParcAuth({
      issuer,
      audience: "parc-tenant-admin",
      keys: jwks,
      allowPlatformTenant: true,
    }),
    service: (client, scope, tenantId) =>
      sign({
        sub: client,
        client_id: client,
        token_use: "service",
        tenant_id: tenantId,
        scope,
      }),
    administrator: (
      administratorId,
      tenantId,
      scope = "tenant.administration",
    ) =>
      sign({
        sub: administratorId,
        client_id: "parc-admin-bff",
        token_use: "delegated",
        tenant_id: tenantId,
        scope,
        subject_type: "ADMINISTRATOR",
        subject_scope: tenantId === null ? "PLATFORM" : "TENANT",
        session_id: randomUUID(),
        act: { sub: "parc-admin-bff" },
      }),
    customer: (customerId, tenantId, scope) =>
      sign({
        sub: customerId,
        client_id: "parc-mobile-bff",
        token_use: "delegated",
        tenant_id: tenantId,
        scope,
        subject_type: "CUSTOMER",
        subject_scope: "TENANT",
        session_id: randomUUID(),
        act: { sub: "parc-mobile-bff" },
      }),
  };
}
