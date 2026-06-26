#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Load optional .env
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

BASE_URL="${BASE_URL:-http://localhost:3000}"
PLATFORM="${PLATFORM:-web}"
# Headless is required for Maestro web tests in CI (GitHub Actions, etc.)
HEADLESS="${HEADLESS:-${CI:+true}}"
HEADLESS="${HEADLESS:-false}"
REPORT_DIR="${REPORT_DIR:-reports/junit}"
FLOW="${FLOW:-flows/e2e/banking-full-journey.yaml}"
USER_ID="${USER_ID:-user-standard-us}"

mkdir -p "$REPORT_DIR"

echo "==> Resolving test data for user: $USER_ID"
ENV_ARGS=()
while IFS='=' read -r key value; do
  [[ -n "$key" ]] && ENV_ARGS+=("-e" "${key}=${value}")
done < <(node scripts/resolve-scenario.js "$USER_ID")

ENV_ARGS+=("-e" "BASE_URL=${BASE_URL}")

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
JUNIT_FILE="${REPORT_DIR}/e2e-${USER_ID}-${TIMESTAMP}.xml"

MAESTRO_ARGS=(-p "$PLATFORM")
if [[ "$HEADLESS" == "true" ]]; then
  MAESTRO_ARGS+=(--headless)
fi

echo "==> Running Maestro E2E flow: $FLOW (platform: $PLATFORM)"
maestro test \
  "${MAESTRO_ARGS[@]}" \
  "${ENV_ARGS[@]}" \
  --format junit \
  --output "$JUNIT_FILE" \
  "$FLOW"

echo "==> JUnit report: $JUNIT_FILE"

if [[ "${GENERATE_ALLURE:-false}" == "true" ]]; then
  GENERATE_ALLURE=true JUNIT_INPUT="$JUNIT_FILE" ./scripts/generate-allure-report.sh
fi

if [[ "${UPLOAD_XRAY:-false}" == "true" ]]; then
  JUNIT_INPUT="$JUNIT_FILE" ./scripts/xray-upload.sh
fi

if [[ "${UPLOAD_REPORTPORTAL:-false}" == "true" ]]; then
  JUNIT_INPUT="$JUNIT_FILE" ./scripts/upload-reportportal.sh
fi
