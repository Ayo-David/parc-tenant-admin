import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import type { Knex } from "knex";
import { z } from "zod";
import { ApiError } from "../http/api-error.js";
import { withPlatformTransaction } from "../database/transaction.js";
import type {
  ConsentDocumentService,
  ConsentDocumentView,
} from "./consent-document-service.js";

const division = z.object({
  id: z.string(),
  level: z.number(),
  name: z.object({ en: z.string(), slug: z.string() }),
  parent: z.object({ id: z.string() }).nullable(),
});
const dataset = z.object({ data: z.array(division) });

export interface OnboardingReferenceData {
  consent_documents: ConsentDocumentView[];
  states: Array<{ code: string; name: string; lgas: string[] }>;
  occupations: string[];
  annual_income_bands: Array<{ code: string; label: string }>;
}

const occupations = [
  "EMPLOYED_PRIVATE_SECTOR",
  "EMPLOYED_GOVERNMENT",
  "SELF_EMPLOYED_FREELANCER",
  "BUSINESS_OWNER",
  "STUDENT",
  "RETIRED",
  "UNEMPLOYED",
  "OTHER",
];
const annualIncomeBands = [
  ["BELOW_500K", "Below ₦500,000"],
  ["NGN_500K_1_999M", "₦500,000 – ₦1,999,999"],
  ["NGN_2M_4_999M", "₦2,000,000 – ₦4,999,999"],
  ["NGN_5M_9_999M", "₦5,000,000 – ₦9,999,999"],
  ["NGN_10M_24_999M", "₦10,000,000 – ₦24,999,999"],
  ["NGN_25M_PLUS", "₦25,000,000 and above"],
  ["PREFER_NOT_TO_SAY", "Prefer not to say"],
] as const;

export class OnboardingReferenceDataService {
  private nigeria?: Promise<Omit<OnboardingReferenceData, "consent_documents">>;
  public constructor(
    private readonly database: Knex,
    private readonly consents: ConsentDocumentService,
  ) {}

  public async resolve(tenantId: string): Promise<OnboardingReferenceData> {
    const tenant = await withPlatformTransaction(this.database, (tx) =>
      tx("tenants")
        .where({ id: tenantId })
        .whereNull("deleted_at")
        .first<{ country_code: string }>("country_code"),
    );
    if (!tenant)
      throw new ApiError(404, "TENANT_NOT_FOUND", "Tenant was not found");
    if (tenant.country_code.trim().toUpperCase() !== "NG")
      throw new ApiError(
        422,
        "ONBOARDING_REFERENCE_OVERRIDE_REQUIRED",
        "A tenant onboarding reference-data override is required outside Nigeria",
      );
    this.nigeria ??= this.loadNigeria();
    return {
      ...(await this.nigeria),
      consent_documents: await this.consents.listCurrent(tenantId),
    };
  }

  private async loadNigeria(): Promise<
    Omit<OnboardingReferenceData, "consent_documents">
  > {
    const filename = fileURLToPath(
      new URL(
        "../reference-data/nigeria-administrative-divisions.json",
        import.meta.url,
      ),
    );
    const parsed = dataset.parse(JSON.parse(await readFile(filename, "utf8")));
    const states = parsed.data.filter((item) => item.level === 1);
    const lgasByState = new Map<string, string[]>();
    for (const item of parsed.data.filter(
      (entry) => entry.level === 2 && entry.parent !== null,
    )) {
      const values = lgasByState.get(item.parent!.id) ?? [];
      values.push(item.name.en);
      lgasByState.set(item.parent!.id, values);
    }
    return {
      states: states.map((state) => ({
        code: state.id,
        name: state.name.en,
        lgas: (lgasByState.get(state.id) ?? []).sort(),
      })),
      occupations: [...occupations],
      annual_income_bands: annualIncomeBands.map(([code, label]) => ({
        code,
        label,
      })),
    };
  }
}
