@ui @BANK-500
Feature: Full banking journey
  End-to-end flow from registration to payment

  Scenario: Complete journey for user-standard-us
    When the customer completes the full banking journey with profile "user-standard-us"
    Then the banking journey is complete

  Scenario: Complete journey for user-premium-uk
    When the customer completes the full banking journey with profile "user-premium-uk"
    Then the banking journey is complete

  Scenario: Complete journey for user-savings-ca
    When the customer completes the full banking journey with profile "user-savings-ca"
    Then the banking journey is complete
