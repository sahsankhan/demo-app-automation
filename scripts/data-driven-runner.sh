#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

USERS_FILE="data/users/onboarding-users.json"
TAG_FILTER="${TAG_FILTER:-}"
PARALLEL="${PARALLEL:-false}"
FAILED=0

echo "==> Data-driven Maestro runner"
echo "    Users file: $USERS_FILE"
echo "    Tag filter: ${TAG_FILTER:-all}"

mapfile -t USER_IDS < <(node -e "
const data = require('./${USERS_FILE}');
const tag = process.env.TAG_FILTER || '';
const users = data.users.filter(u => !tag || (u.tags || []).includes(tag));
users.forEach(u => console.log(u.id));
if (!users.length) process.exit(1);
")

echo "==> Executing ${#USER_IDS[@]} scenario(s)"

run_user() {
  local user_id="$1"
  echo ""
  echo "---- Scenario: $user_id ----"
  if USER_ID="$user_id" ./scripts/run-e2e.sh; then
    echo "PASS: $user_id"
  else
    echo "FAIL: $user_id"
    return 1
  fi
}

if [[ "$PARALLEL" == "true" ]]; then
  pids=()
  for user_id in "${USER_IDS[@]}"; do
    run_user "$user_id" &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid" || FAILED=$((FAILED + 1))
  done
else
  for user_id in "${USER_IDS[@]}"; do
    run_user "$user_id" || FAILED=$((FAILED + 1))
  done
fi

if [[ "$FAILED" -gt 0 ]]; then
  echo "==> $FAILED scenario(s) failed"
  exit 1
fi

echo "==> All data-driven scenarios passed"
