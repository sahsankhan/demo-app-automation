#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

USER_ID="${USER_ID:-user-standard-us}"

echo "============================================"
echo " Demo App — Full Test Suite"
echo " User profile: $USER_ID"
echo "============================================"

if [[ "${API_ONLY:-false}" != "true" ]]; then
  echo ""
  echo ">> API tests (Karate)"
  ./scripts/run-api-tests.sh
fi

if [[ "${UI_ONLY:-false}" != "true" ]]; then
  echo ""
  echo ">> UI tests (Cucumber + POM)"
  ./scripts/run-ui-bdd.sh
fi

echo ""
echo ">> Allure report"
GENERATE_ALLURE=true ./scripts/generate-allure-report.sh

echo ""
echo "Done. Reports:"
echo "  API : reports/karate/"
echo "  UI  : reports/cucumber-ui/"
echo "  HTML: allure-report/"
