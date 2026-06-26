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

: "${RP_ENDPOINT:?Set RP_ENDPOINT in .env}"
: "${RP_PROJECT:?Set RP_PROJECT in .env}"
: "${RP_TOKEN:?Set RP_TOKEN in .env}"

JUNIT_DIR="${JUNIT_DIR:-reports/junit}"
LAUNCH_NAME="${RP_LAUNCH_NAME:-Demo App Automation}"
LAUNCH_DESC="${RP_LAUNCH_DESC:-Demo App API and UI test run}"

if [[ -n "${JUNIT_INPUT:-}" && -f "$JUNIT_INPUT" ]]; then
  JUNIT_FILES=("$JUNIT_INPUT")
else
  mapfile -t JUNIT_FILES < <(find "$JUNIT_DIR" -name '*.xml' -type f 2>/dev/null || true)
fi

if [[ ${#JUNIT_FILES[@]} -eq 0 ]]; then
  echo "No JUnit files to upload"
  exit 1
fi

echo "==> Uploading ${#JUNIT_FILES[@]} JUnit file(s) to ReportPortal"

for junit_file in "${JUNIT_FILES[@]}"; do
  node scripts/upload-junit-to-reportportal.js \
    "$junit_file" \
    "$RP_ENDPOINT" \
    "$RP_PROJECT" \
    "$RP_TOKEN" \
    "$LAUNCH_NAME" \
    "$LAUNCH_DESC"
done

echo "==> ReportPortal upload complete"
