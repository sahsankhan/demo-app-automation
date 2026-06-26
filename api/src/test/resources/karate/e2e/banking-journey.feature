Feature: Full banking API journey @BANK-600

  Background:
    * call read('classpath:karate/common/setup.feature')
    * url baseUrl

  Scenario Outline: End-to-end API flow onboarding → KYC → account → payment for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    * def kyc = scenario.kyc
    * def accountData = scenario.account
    * def paymentData = scenario.payment
    * def expectedBalance = scenario.expectedBalance

    Given path 'api', apiVersion, 'onboarding', 'register'
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

    Given path 'api', apiVersion, 'kyc', 'verify'
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

    Given path 'api', apiVersion, 'accounts'
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

    Given path 'api', apiVersion, 'payments'
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

    Given path 'api', apiVersion, 'accounts', accountId, 'balance'
    When method get
    Then status 200
    And match response.balance == expectedBalance
    And assert openingBalance - parseFloat(paymentData.amount) == response.balance

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
