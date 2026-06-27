@ui @BANK-401
Feature: Payments
  Make a payment from an open account

  Scenario: Submit payment for user-standard-us
    Given the customer has an open account with profile "user-standard-us"
    When the customer submits a payment
    Then the payment is successful
