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

APP_ID="${APP_ID:-com.demo.app}"
APK_PATH="${APK_PATH:-mobile-app/build/demo-app-debug.apk}"
PLATFORM="${PLATFORM:-android}"
REPORT_DIR="${REPORT_DIR:-reports/junit}"
FLOW="${FLOW:-flows/mobile/e2e/banking-full-journey.yaml}"
USER_ID="${USER_ID:-user-standard-us}"
ANDROID_HOME="${ANDROID_HOME:-${HOME}/Library/Android/sdk}"
if [[ ! -d "$ANDROID_HOME" && -d "${HOME}/Android/Sdk" ]]; then
  ANDROID_HOME="${HOME}/Android/Sdk"
fi
AVD_NAME="${AVD_NAME:-}"
AUTO_START_EMULATOR="${AUTO_START_EMULATOR:-true}"
EMULATOR_BOOT_TIMEOUT="${EMULATOR_BOOT_TIMEOUT:-180}"

export ANDROID_HOME
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

mkdir -p "$REPORT_DIR"

device_ready() {
  adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'
}

boot_completed() {
  [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]
}

wait_for_emulator() {
  local deadline=$((SECONDS + EMULATOR_BOOT_TIMEOUT))
  echo "Waiting for emulator to boot (timeout: ${EMULATOR_BOOT_TIMEOUT}s)..."
  until boot_completed; do
    if (( SECONDS >= deadline )); then
      echo "Emulator did not finish booting within ${EMULATOR_BOOT_TIMEOUT}s."
      exit 1
    fi
    sleep 2
  done
  adb wait-for-device
  echo "Emulator is ready."
}

start_emulator_if_needed() {
  if device_ready; then
    return 0
  fi

  if [[ "$AUTO_START_EMULATOR" != "true" ]]; then
    echo "No Android device/emulator detected."
    echo "Start an emulator (Android Studio > Device Manager) or set AUTO_START_EMULATOR=true."
    exit 1
  fi

  if ! command -v emulator >/dev/null 2>&1; then
    echo "No device found and emulator binary is missing from PATH."
    echo "Set ANDROID_HOME to your Android SDK and install an AVD."
    exit 1
  fi

  if [[ -z "$AVD_NAME" ]]; then
    AVD_NAME="$(emulator -list-avds | head -n 1)"
  fi

  if [[ -z "$AVD_NAME" ]]; then
    echo "No Android Virtual Device found."
    echo "Create one in Android Studio > Device Manager, then retry."
    exit 1
  fi

  echo "Starting emulator: $AVD_NAME"
  nohup emulator -avd "$AVD_NAME" -no-snapshot-save -no-boot-anim >/tmp/demo-app-emulator.log 2>&1 &
  wait_for_emulator
}

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found — building..."
  ./scripts/build-mobile-apk.sh
fi

echo "Checking for a connected Android device or emulator..."
start_emulator_if_needed

echo "Installing APK: $APK_PATH"
adb install -r "$APK_PATH" >/dev/null

echo "Clearing app data for a clean run..."
adb shell pm clear "$APP_ID" >/dev/null || true

if [[ "${CI:-false}" == "true" ]]; then
  echo "Waiting for emulator WebView subsystem on CI..."
  adb shell settings put global webview_provider com.google.android.webview 2>/dev/null || true
  sleep 3
fi

echo "Resolving test data for user: $USER_ID"
ENV_ARGS=()
while IFS='=' read -r key value; do
  [[ -n "$key" ]] && ENV_ARGS+=("-e" "${key}=${value}")
done < <(node scripts/resolve-scenario.js "$USER_ID")

ENV_ARGS+=("-e" "APP_ID=${APP_ID}")

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
JUNIT_FILE="${REPORT_DIR}/mobile-${USER_ID}-${TIMESTAMP}.xml"

echo "Running mobile flow: $FLOW (app: $APP_ID)"
maestro test \
  -p "$PLATFORM" \
  "${ENV_ARGS[@]}" \
  --format junit \
  --output "$JUNIT_FILE" \
  "$FLOW"

echo "JUnit report: $JUNIT_FILE"
