@ui @smoke @BANK-101
Feature: Onboarding
  Register a new customer on Demo App

  Scenario: Successful registration for user-standard-us
    Given the Demo App home page is open
    When the customer registers using profile "user-standard-us"
    Then registration is successful
