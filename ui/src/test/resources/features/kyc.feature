@ui @BANK-201
Feature: KYC verification
  Verify customer identity after registration

  Scenario: Successful KYC for user-standard-us
    Given the customer is registered with profile "user-standard-us"
    When the customer completes KYC verification
    Then KYC verification is successful
