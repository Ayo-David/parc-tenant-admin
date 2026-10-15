#!/usr/bin/env bash
# Publishes a tenant's Terms, Privacy and KYC consent documents.
#
# Downloads each policy document, uses the SHA-256 of its exact bytes as the
# evidence digest customers consent to, then runs seed-consent-documents.sql
# as the schema owner. Safe to re-run: unchanged documents are skipped, and a
# changed document needs a new CONSENT_DOCUMENT_VERSION.
#
#   TENANT_ID=<uuid> \
#   TERMS_URL=https://... PRIVACY_URL=https://... KYC_URL=https://... \
#   CONSENT_DOCUMENT_VERSION=1.0 \
#   DATABASE_URL="$MIGRATION_DATABASE_URL" \
#   scripts/seed-consent-documents.sh
#
# Set PSQL to run psql another way, e.g. PSQL="docker exec -i postgres psql".
set -euo pipefail

: "${TENANT_ID:?TENANT_ID is required}"
: "${TERMS_URL:?TERMS_URL is required}"
: "${PRIVACY_URL:?PRIVACY_URL is required}"
: "${KYC_URL:?KYC_URL is required}"
: "${DATABASE_URL:?DATABASE_URL is required (use the migrator login)}"
CONSENT_DOCUMENT_VERSION="${CONSENT_DOCUMENT_VERSION:-1.0}"
PSQL="${PSQL:-psql}"
here="$(cd "$(dirname "$0")" && pwd)"

digest_of() {
  local url="$1"
  case "$url" in https://*) ;; *) echo "Policy URL must use https: $url" >&2; exit 1 ;; esac
  local body
  body="$(mktemp)"
  if ! curl --fail --silent --show-error --location --max-time 30 --output "$body" "$url"; then
    rm -f "$body"
    echo "Could not download $url" >&2
    exit 1
  fi
  if [ ! -s "$body" ]; then
    rm -f "$body"
    echo "Empty document at $url" >&2
    exit 1
  fi
  if command -v sha256sum >/dev/null; then sha256sum "$body" | cut -d' ' -f1; else shasum -a 256 "$body" | cut -d' ' -f1; fi
  rm -f "$body"
}

terms_digest="$(digest_of "$TERMS_URL")"
privacy_digest="$(digest_of "$PRIVACY_URL")"
kyc_digest="$(digest_of "$KYC_URL")"

$PSQL "$DATABASE_URL" -X -v ON_ERROR_STOP=1 \
  -v tenant_id="$TENANT_ID" \
  -v document_version="$CONSENT_DOCUMENT_VERSION" \
  -v terms_url="$TERMS_URL" -v terms_digest="$terms_digest" \
  -v privacy_url="$PRIVACY_URL" -v privacy_digest="$privacy_digest" \
  -v kyc_url="$KYC_URL" -v kyc_digest="$kyc_digest" \
  -f - < "$here/seed-consent-documents.sql"
