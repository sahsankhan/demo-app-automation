#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

: "${JIRA_BASE_URL:?Set JIRA_BASE_URL in .env}"
: "${XRAY_CLIENT_ID:?Set XRAY_CLIENT_ID in .env}"
: "${XRAY_CLIENT_SECRET:?Set XRAY_CLIENT_SECRET in .env}"
: "${XRAY_TEST_EXECUTION_KEY:?Set XRAY_TEST_EXECUTION_KEY in .env}"

JUNIT_DIR="${JUNIT_DIR:-reports/junit}"

if [[ -n "${JUNIT_INPUT:-}" && -f "$JUNIT_INPUT" ]]; then
  JUNIT_FILES=("$JUNIT_INPUT")
else
  mapfile -t JUNIT_FILES < <(find "$JUNIT_DIR" -name '*.xml' -type f 2>/dev/null || true)
fi

if [[ ${#JUNIT_FILES[@]} -eq 0 ]]; then
  echo "No JUnit files to upload to Xray"
  exit 1
fi

echo "==> Uploading results to Xray execution: $XRAY_TEST_EXECUTION_KEY"

for junit_file in "${JUNIT_FILES[@]}"; do
  node scripts/xray-import-junit.js \
    "$junit_file" \
    "$JIRA_BASE_URL" \
    "$XRAY_CLIENT_ID" \
    "$XRAY_CLIENT_SECRET" \
    "$XRAY_TEST_EXECUTION_KEY"
done

echo "==> Xray import complete"
