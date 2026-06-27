#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

JUNIT_DIR="${JUNIT_DIR:-reports/junit}"
ALLURE_RESULTS="${ALLURE_RESULTS:-allure-results}"
ALLURE_REPORT="${ALLURE_REPORT:-allure-report}"

mkdir -p "$ALLURE_RESULTS"

echo "==> Converting JUnit XML to Allure results"

if [[ -n "${JUNIT_INPUT:-}" && -f "$JUNIT_INPUT" ]]; then
  JUNIT_FILES=("$JUNIT_INPUT")
else
    mapfile -t JUNIT_FILES < <(
    find reports/junit reports/karate reports/cucumber-ui reports/surefire -name '*.xml' -type f 2>/dev/null | sort -u || true
  )
fi

if [[ ${#JUNIT_FILES[@]} -eq 0 ]]; then
  echo "No JUnit files found in reports/junit or reports/karate"
  exit 1
fi

for junit_file in "${JUNIT_FILES[@]}"; do
  node scripts/junit-to-allure.js "$junit_file" "$ALLURE_RESULTS"
done

echo "==> Generating Allure HTML report"
if command -v allure >/dev/null 2>&1; then
  allure generate "$ALLURE_RESULTS" --clean -o "$ALLURE_REPORT"
elif [[ -x node_modules/.bin/allure ]]; then
  npx allure generate "$ALLURE_RESULTS" --clean -o "$ALLURE_REPORT"
else
  npx --yes allure-commandline generate "$ALLURE_RESULTS" --clean -o "$ALLURE_REPORT"
fi

echo "==> Allure report: $ALLURE_REPORT/index.html"
