# Mobile app

Android WebView app that packages the same HTML/CSS/JS as `mock-app/`. Used for Maestro mobile demos.

| Item | Value |
|---|---|
| Application ID | `com.demo.app` |
| Debug APK | `mobile-app/build/demo-app-debug.apk` |

## Build

```bash
npm run mobile:build
```

Assets are copied from `mock-app/` during the build (`scripts/sync-mobile-assets.sh`).

## Test

Requires an Android emulator or device:

```bash
npm run test:mobile
```

The test runner starts the first available AVD if none is running. Override with `AVD_NAME=Your_AVD`.
