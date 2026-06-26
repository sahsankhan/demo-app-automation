#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

chmod +x scripts/*.sh

if ! curl -sf "http://localhost:3000" >/dev/null 2>&1; then
  npx --yes serve mock-app -l 3000 &
  WEB_PID=$!
  npx --yes wait-on http://localhost:3000
  trap 'kill "$WEB_PID" 2>/dev/null || true' EXIT
fi

./scripts/run-api-tests.sh
TAG_FILTER=regression ./scripts/data-driven-runner.sh

echo "Regression tests passed."
