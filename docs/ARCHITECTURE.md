# Architecture

How the Demo App test framework is organized.

## Layers

| Layer | Folder | Tool | Role |
|---|---|---|---|
| Data | `data/` | JSON | Single source of test profiles |
| API BDD | `api/` + `mock-api/` | Karate (Gherkin) | REST flows with chained requests |
| UI BDD + POM | `ui/` + `mock-app/` | Cucumber + Selenium | Gherkin scenarios + page objects |
| UI (alt) | `flows/` | Maestro | Web journeys (optional runner) |
| Mobile | `flows/mobile/` + `mobile-app/` | Maestro + APK | Android banking journey |
| Test | `scripts/` | Bash | Runners and reporting hooks |
| CI | `.github/workflows/` | GitHub Actions | Automated runs on every change |

## Maven modules

```
pom.xml                 Parent aggregator
├── api/                banking-api-tests   (Karate only)
└── ui/                 banking-ui-tests    (Cucumber + Selenium only)
```

Both modules share test data via Maven `testResources` that link to `data/` and `config/`.

## Flow

```
         config/journey-map.json  (single source of truth)
                    │
    ┌───────────────┴───────────────┐
    ▼                               ▼
 UI pages + transitions        API route segments
    │                               │
 ui/pages/*Page.java           routes.js (Karate)
 ui/steps + ui/flows               │
    │                          Given path routes.*
 mock-app/*.html               mock-api endpoints
```

### UI BDD: feature → steps → flows → pages

| Layer | Location | Responsibility |
|---|---|---|
| Feature | `ui/.../features/*.feature` | Gherkin scenarios (`@ui`, `@smoke`, `@BANK-xxx`) |
| Steps | `ui/.../steps/*Steps.java` | Maps Gherkin to flow/page calls (one class per domain) |
| Flows | `ui/.../flows/BankingJourneyFlow.java` | Composes multi-page journeys |
| Pages | `ui/.../pages/*Page.java` | Locators (`Route`, `Locators`, `Text`), actions, assertions |
| Data | `ui/.../data/ScenarioLoader.java` | Loads shared JSON by `userId` |
| Hooks | `ui/.../hooks/WebDriverHooks.java` | Chrome lifecycle per `@ui` scenario |

Example:

```gherkin
When the customer registers using profile "user-standard-us"
```

→ `OnboardingSteps` → `BankingJourneyFlow.registerCustomer()` → `OnboardingPage.fillRegistrationForm(...)`

### API BDD: feature → steps → routes

Karate features live under `api/src/test/resources/karate/` and use `routes.js`:

```gherkin
* def routes = call read('classpath:karate/common/routes.js')
Given path routes.onboarding
```

### Maestro (optional alternate UI runner)

| Layer | File pattern | Responsibility |
|---|---|---|
| Feature (standalone) | `flows/*/register-user.yaml` | `go-to-page` → `*-steps` |
| E2E orchestrator | `flows/e2e/banking-full-journey.yaml` | page → steps → **continue** → steps → … |
| Steps only | `flows/*/register-steps.yaml` | Form actions — **no navigation** |
| Navigation | `flows/shared/go-to-page.yaml` | Open a page once |
| Transition | `flows/shared/continue-to-next.yaml` | Tap Continue (no `openLink` reload) |

```
         data/users ──┐
         data/kyc  ──┼──> ScenarioLoader.java  ──> ui/ (Cucumber + POM)
         data/pay   ──┤
                     └──> load-scenario.js     ──> api/ (Karate)

Karate ──> mock-api:4000          Selenium ──> mock-app:3000
   │                                    │
   └──────── JUnit ──> Allure / Xray / ReportPortal
```

## Banking journey (both layers)

```
Register → KYC → Open account → Payment → Balance check
```

API tests chain HTTP calls and assert status codes and response bodies. UI BDD tests walk through the Demo App screens via page objects and assert visible outcomes.

## CI pipeline

File: `.github/workflows/ci.yml`

Triggers: push, pull_request, workflow_dispatch

Jobs: api-tests → ui-tests → mobile-tests → UI regression → allure-report → xray / reportportal
