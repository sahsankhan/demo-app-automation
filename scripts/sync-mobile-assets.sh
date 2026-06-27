#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/mock-app"
DEST="$ROOT_DIR/mobile-app/android/app/src/main/assets/www"

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"

echo "Synced mock-app assets -> mobile-app/android/app/src/main/assets/www"
