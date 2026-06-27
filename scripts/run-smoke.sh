#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

chmod +x scripts/*.sh

./scripts/run-api-tests.sh
CUCUMBER_TAGS="@ui and @smoke" ./scripts/run-ui-bdd.sh

echo "Smoke tests passed."
