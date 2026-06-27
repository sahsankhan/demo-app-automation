#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_HOME="${ANDROID_HOME:-${HOME}/Library/Android/sdk}"
if [[ ! -d "$ANDROID_HOME" && -d "${HOME}/Android/Sdk" ]]; then
  ANDROID_HOME="${HOME}/Android/Sdk"
fi

export ANDROID_HOME
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

OUTPUT_DIR="$ROOT_DIR/mobile-app/build"
APK_OUT="$OUTPUT_DIR/demo-app-debug.apk"
GRADLE_DIR="$ROOT_DIR/mobile-app/android"

chmod +x scripts/sync-mobile-assets.sh
./scripts/sync-mobile-assets.sh

mkdir -p "$OUTPUT_DIR"

if [[ ! -x "$GRADLE_DIR/gradlew" ]]; then
  echo "Bootstrapping Gradle wrapper..."
  curl -fsSL -o "$GRADLE_DIR/gradlew" \
    "https://raw.githubusercontent.com/gradle/gradle/v8.7.0/gradlew"
  chmod +x "$GRADLE_DIR/gradlew"
  curl -fsSL -o "$GRADLE_DIR/gradle/wrapper/gradle-wrapper.jar" \
    "https://github.com/gradle/gradle/raw/v8.7.0/gradle/wrapper/gradle-wrapper.jar"
fi

if [[ ! -d "$ANDROID_HOME/platforms/android-34" ]]; then
  echo "Installing Android SDK platform 34..."
  yes | sdkmanager "platforms;android-34" "build-tools;34.0.0" >/dev/null
fi

echo "Building debug APK..."
(cd "$GRADLE_DIR" && ./gradlew assembleDebug --no-daemon -q)

cp "$GRADLE_DIR/app/build/outputs/apk/debug/app-debug.apk" "$APK_OUT"

echo "APK ready: $APK_OUT"
echo "App ID: com.demo.app"
