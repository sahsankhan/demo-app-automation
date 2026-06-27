@ui @BANK-301
Feature: Account opening
  Open a bank account after KYC

  Scenario: Open account for user-standard-us
    Given the customer has verified KYC with profile "user-standard-us"
    When the customer opens a bank account
    Then the account is opened successfully
