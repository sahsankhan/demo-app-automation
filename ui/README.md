# UI tests

Cucumber BDD with Selenium page objects.

## Structure

```
features/     Gherkin scenarios
steps/        Step definitions (one class per area)
flows/        Multi-page journey helpers
pages/        Page objects (locators and actions)
data/         Loads shared JSON by userId
hooks/        WebDriver setup for @ui scenarios
```

## Run

```bash
npm run mock:serve
npm run test:ui
```

Or from this module:

```bash
mvn clean test -Dtest=UiCucumberTest
```

Reports are written to `reports/cucumber-ui/`.
