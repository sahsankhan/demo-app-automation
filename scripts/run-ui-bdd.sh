#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_URL="${BASE_URL:-http://localhost:3000}"
export BASE_URL
export CI="${CI:-false}"

mkdir -p reports/cucumber-ui

if ! curl -sf "$BASE_URL" >/dev/null 2>&1; then
  echo "Starting Demo App web UI on $BASE_URL"
  npx --yes serve mock-app -l 3000 &
  WEB_PID=$!
  npx --yes wait-on "$BASE_URL"
  trap 'kill "$WEB_PID" 2>/dev/null || true' EXIT
fi

echo "Running UI BDD tests (Cucumber + Selenium POM)..."
TAGS="${CUCUMBER_TAGS:-@ui}"
(cd ui && mvn -q clean test -Dtest=UiCucumberTest "-Dcucumber.filter.tags=${TAGS}")

echo "Cucumber report: reports/cucumber-ui/cucumber.xml"
