# Demo App Test Automation

End-to-end test framework for a sample banking application. Covers API (Karate), web UI (Cucumber + Selenium POM), and Android mobile (Maestro). Shared JSON test data drives all layers.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for design notes.

## Repository layout

```
api/           Karate API tests (Maven module)
ui/            Cucumber + Selenium UI tests (Maven module)
mobile-app/    Android demo app (WebView wrapper around mock-app)
flows/         Maestro flows for web and mobile
mock-api/      REST API for Karate
mock-app/      Web UI under test
data/          Shared test profiles (JSON)
config/        Journey map and environment config
scripts/       Shell runners
```

## Prerequisites

- Node 18+
- Java 17+ and Maven 3.8+
- Chrome (UI tests)
- Android SDK and Maestro CLI (mobile tests)
- Maestro CLI (optional, for Maestro web flows)

```bash
chmod +x scripts/*.sh
```

## Quick start

Start the apps:

```bash
npm run mock:api    # port 4000
npm run mock:serve  # port 3000
```

Run tests:

```bash
npm run test:api       # Karate
npm run test:ui        # Cucumber + POM
npm run test:mobile    # Maestro on Android (starts emulator if needed)
npm run test:smoke     # API + UI smoke
```

Build the Android APK:

```bash
npm run mobile:build
# -> mobile-app/build/demo-app-debug.apk
```

Filter UI scenarios by tag:

```bash
CUCUMBER_TAGS="@ui and @smoke" npm run test:ui
```

## Test coverage

| Step | API | Web UI | Maestro web | Maestro mobile |
|---|---|---|---|---|
| Onboarding | Karate | Cucumber | `flows/onboarding/` | `flows/mobile/onboarding/` |
| KYC | Karate | Cucumber | `flows/kyc/` | `flows/mobile/kyc/` |
| Account | Karate | Cucumber | `flows/account/` | `flows/mobile/account/` |
| Payment | Karate | Cucumber | `flows/payment/` | `flows/mobile/payment/` |
| Full journey | Karate e2e | Cucumber e2e | `flows/e2e/` | `flows/mobile/e2e/` |

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on push, pull request, and manual dispatch:

- API tests (Karate)
- UI tests (Cucumber)
- Mobile tests (APK build + Maestro on emulator)
- UI regression by tag
- Allure report upload
- Optional Xray and ReportPortal on main

## Reporting

```bash
npm run report:allure
```

Configure `.env` from `.env.example` for ReportPortal (`RP_*`) and Xray (`XRAY_*`).

## License

MIT
