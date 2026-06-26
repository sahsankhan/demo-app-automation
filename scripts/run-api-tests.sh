#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

API_PORT="${API_PORT:-4000}"
KARATE_ENV="${KARATE_ENV:-local}"
USER_ID="${USER_ID:-}"

mkdir -p reports/karate

echo "Starting Demo App API on port $API_PORT"
node mock-api/server.js &
API_PID=$!

cleanup() {
  kill "$API_PID" 2>/dev/null || true
}
trap cleanup EXIT

for i in {1..30}; do
  if curl -sf "http://localhost:${API_PORT}/api/v1/health" >/dev/null; then
    break
  fi
  sleep 1
done

echo "Running Karate API tests..."
MVN_ARGS=(-Dkarate.env="$KARATE_ENV")
if [[ -n "$USER_ID" ]]; then
  MVN_ARGS+=("-DuserId=$USER_ID")
fi

(cd api && mvn -q test "${MVN_ARGS[@]}")

echo "==> Karate reports: reports/karate/"

if [[ "${GENERATE_ALLURE:-false}" == "true" ]]; then
  ./scripts/generate-allure-report.sh
fi

if [[ "${UPLOAD_XRAY:-false}" == "true" ]]; then
  JUNIT_DIR=reports/karate ./scripts/xray-upload.sh
fi
