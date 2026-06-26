# Demo App — Test Automation Framework

Automated tests for **Demo App**, a sample banking product. Covers API (Karate), web UI (Maestro), shared test data, Allure/ReportPortal reporting, GitHub Actions CI, and optional Xray traceability.

## What gets tested

| Flow step | API test | UI test |
|---|---|---|
| Onboarding | `api/.../onboarding/register.feature` | `flows/onboarding/register-user.yaml` |
| KYC | `api/.../kyc/verify.feature` | `flows/kyc/verify-identity.yaml` |
| Account | `api/.../account/open-account.feature` | `flows/account/setup-account.yaml` |
| Payment | `api/.../payment/transfer.feature` | `flows/payment/make-payment.yaml` |
| Full journey | `api/.../e2e/banking-journey.feature` | `flows/e2e/banking-full-journey.yaml` |
| Business rules | `api/.../e2e/business-validations.feature` | — |

Architecture details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Project layout

```
api/           Karate API tests
flows/         Maestro web UI tests
flows/mobile/  Maestro mobile template
mock-api/      REST API used by Karate
mock-app/      Web UI used by Maestro
data/          Shared test data (JSON)
scripts/       Test runners
.github/       CI pipeline
```

## Setup

**Requirements:** Node 18+, Java 17+, Maven 3.8+, [Maestro CLI](https://maestro.mobile.dev)

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
echo 'export PATH="$HOME/.maestro/bin:$PATH"' >> ~/.zshrc
chmod +x scripts/*.sh
```

## Run tests locally

**Option A — smoke (API + one UI journey)**

```bash
npm run test:smoke
```

**Option B — run layers separately**

```bash
# Terminal 1
npm run mock:api    # http://localhost:4000
npm run mock:serve  # http://localhost:3000

# Terminal 2
npm run test:api
npm run test:ui
```

**Other commands**

```bash
npm run test:regression    # full API + tagged UI scenarios
npm run test:data-driven   # all UI user profiles
npm run test:full          # API + UI + Allure
npm run report:allure      # generate HTML report
```

## CI/CD

Pipeline: `.github/workflows/ci.yml`

Runs on **every push, pull request, and manual trigger**:

1. API tests (Karate)
2. UI tests (Maestro web)
3. Data-driven regression (smoke + regression tags)
4. Allure report artifact
5. Xray + ReportPortal (main branch, when secrets are configured)

## Test data

Shared JSON in `data/` — same profiles drive both API and UI:

- `data/users/onboarding-users.json`
- `data/kyc/kyc-scenarios.json`
- `data/payments/payment-scenarios.json`

```bash
USER_ID=user-premium-uk npm run test:ui
TAG_FILTER=smoke npm run test:data-driven
```

## Reporting & traceability

- **Allure:** `npm run report:allure` → `allure-report/index.html`
- **ReportPortal:** set `RP_*` in `.env`, then `npm run report:portal`
- **Xray:** tests tagged `@BANK-xxx` in feature files; set `XRAY_*` in `.env`

Copy `.env.example` to `.env` for integration credentials.

## Pointing at your own app

```bash
export BASE_URL=https://your-staging-app.com
export API_URL=https://your-staging-api.com
```

Update selectors in `flows/` and endpoints in `api/` Karate features.

## License

MIT
