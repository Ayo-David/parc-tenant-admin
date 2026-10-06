import { importSPKI } from "jose";

type VerificationKey = Awaited<ReturnType<typeof importSPKI>>;

/** Imports Auth's static RS256 verification keys: `{ "<kid>": "<base64 SPKI PEM>" }`. */
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
