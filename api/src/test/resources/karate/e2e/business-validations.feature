Feature: API business rule validations @BANK-621

  Background:
    * call read('classpath:karate/common/setup.feature')
    * def routes = call read('classpath:karate/common/routes.js')
    * url baseUrl

  Scenario: Reject account opening when KYC is not completed
    Given path routes.onboarding
    And request { firstName: 'Test', lastName: 'User', email: 'no-kyc@example.com', phone: '+10000000001', password: 'TestPass123!' }
    When method post
    Then status 201
    * def customerId = response.customerId

    Given path routes.account
    And request { customerId: '#(customerId)', accountType: 'checking', currency: 'USD', initialDeposit: '100.00' }
    When method post
    Then status 403
    And match response.error == 'KYC_REQUIRED'

  Scenario: Reject payment when insufficient funds
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: 'user-standard-us' }
    * def user = scenario.user
    * def kyc = scenario.kyc

    Given path routes.onboarding
    And request { firstName: '#(user.firstName)', lastName: '#(user.lastName)', email: 'insufficient@example.com', phone: '#(user.phone)', password: '#(user.password)' }
    When method post
    Then status 201
    * def customerId = response.customerId

    Given path routes.kyc
    And request { customerId: '#(customerId)', dateOfBirth: '#(kyc.dateOfBirth)', nationalId: '#(kyc.nationalId)', address: '#(kyc.address)', city: '#(kyc.city)', country: '#(kyc.country)', documentType: '#(kyc.documentType)' }
    When method post
    Then status 200

    Given path routes.account
    And request { customerId: '#(customerId)', accountType: 'checking', currency: 'USD', initialDeposit: '10.00' }
    When method post
    Then status 201
    * def accountId = response.accountId

    Given path routes.payment
    And request { accountId: '#(accountId)', beneficiary: 'Jane Doe', beneficiaryAccount: 'ACC-000', amount: '999.00', reference: 'Overdraft test' }
    When method post
    Then status 422
    And match response.error == 'INSUFFICIENT_FUNDS'
