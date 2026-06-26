# Architecture

How the Demo App test framework is organized.

## Layers

| Layer | Folder | Tool | Role |
|---|---|---|---|
| Data | `data/` | JSON | Single source of test profiles |
| API | `api/` + `mock-api/` | Karate | REST flows with chained requests |
| UI | `flows/` + `mock-app/` | Maestro | Web end-user journeys |
| Mobile | `flows/mobile/` | Maestro | Native app template |
| Test | `scripts/` | Bash | Runners and reporting hooks |
| CI | `.github/workflows/` | GitHub Actions | Automated runs on every change |

## Flow

```
         data/users ──┐
         data/kyc  ──┼──> resolve-scenario.js ──> Maestro (UI)
         data/pay   ──┤
                     └──> load-scenario.js     ──> Karate (API)

Karate ──> mock-api:4000          Maestro ──> mock-app:3000
   │                                    │
   └──────── JUnit ──> Allure / Xray / ReportPortal
```

## Banking journey (both layers)

```
Register → KYC → Open account → Payment → Balance check
```

API tests chain HTTP calls and assert status codes and response bodies. UI tests walk through the Demo App screens and assert visible outcomes.

## CI pipeline

File: `.github/workflows/ci.yml`

Triggers: push, pull_request, workflow_dispatch

Jobs: api-tests → ui-tests → regression matrix → allure-report → xray / reportportal
