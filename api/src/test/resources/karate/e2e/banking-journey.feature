Feature: Full banking API journey @BANK-600

  Background:
    * call read('classpath:karate/common/setup.feature')
    * def routes = call read('classpath:karate/common/routes.js')
    * url baseUrl

  Scenario Outline: End-to-end API flow onboarding → KYC → account → payment for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    * def kyc = scenario.kyc
    * def accountData = scenario.account
    * def paymentData = scenario.payment
    * def expectedBalance = scenario.expectedBalance

    # Step 1 — Onboarding
    Given path routes.onboarding
    And header Content-Type = 'application/json'
    And request
      """
      {
        "firstName": "#(user.firstName)",
        "lastName": "#(user.lastName)",
        "email": "#(user.email)",
        "phone": "#(user.phone)",
        "password": "#(user.password)"
      }
      """
    When method post
    Then status 201
    And match response.status == 'REGISTERED'
    * def customerId = response.customerId

    # Step 2 — KYC
    Given path routes.kyc
    And request
      """
      {
        "customerId": "#(customerId)",
        "dateOfBirth": "#(kyc.dateOfBirth)",
        "nationalId": "#(kyc.nationalId)",
        "address": "#(kyc.address)",
        "city": "#(kyc.city)",
        "country": "#(kyc.country)",
        "documentType": "#(kyc.documentType)"
      }
      """
    When method post
    Then status 200
    And match response.kycStatus == 'VERIFIED'

    # Step 3 — Account
    Given path routes.account
    And request
      """
      {
        "customerId": "#(customerId)",
        "accountType": "#(accountData.accountType)",
        "currency": "#(accountData.currency)",
        "initialDeposit": "#(accountData.initialDeposit)"
      }
      """
    When method post
    Then status 201
    And match response.status == 'OPEN'
    * def accountId = response.accountId
    * def openingBalance = response.balance

    # Step 4 — Payment
    Given path routes.payment
    And request
      """
      {
        "accountId": "#(accountId)",
        "beneficiary": "#(paymentData.beneficiary)",
        "beneficiaryAccount": "#(paymentData.beneficiaryAccount)",
        "amount": "#(paymentData.amount)",
        "reference": "#(paymentData.reference)"
      }
      """
    When method post
    Then status 200
    And match response.status == 'SUCCESS'
    And match response.newBalance == expectedBalance

    # Step 5 — Balance check
    * def balancePath = routes.accountBalance(accountId)
    Given path balancePath
    When method get
    Then status 200
    And match response.balance == expectedBalance
    And assert openingBalance - parseFloat(paymentData.amount) == response.balance

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
