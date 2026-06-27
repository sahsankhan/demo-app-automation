Feature: Payment API @BANK-411

  Background:
    * call read('classpath:karate/common/setup.feature')
    * def routes = call read('classpath:karate/common/routes.js')
    * url baseUrl

  Scenario Outline: Submit payment and validate balance for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    * def kyc = scenario.kyc
    * def accountData = scenario.account
    * def paymentData = scenario.payment
    * def expectedBalance = scenario.expectedBalance

    Given path routes.onboarding
    And request { firstName: '#(user.firstName)', lastName: '#(user.lastName)', email: '#(user.email)', phone: '#(user.phone)', password: '#(user.password)' }
    When method post
    Then status 201
    * def customerId = response.customerId

    Given path routes.kyc
    And request { customerId: '#(customerId)', dateOfBirth: '#(kyc.dateOfBirth)', nationalId: '#(kyc.nationalId)', address: '#(kyc.address)', city: '#(kyc.city)', country: '#(kyc.country)', documentType: '#(kyc.documentType)' }
    When method post
    Then status 200

    Given path routes.account
    And request { customerId: '#(customerId)', accountType: '#(accountData.accountType)', currency: '#(accountData.currency)', initialDeposit: '#(accountData.initialDeposit)' }
    When method post
    Then status 201
    * def accountId = response.accountId

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
    And match response contains { transactionId: '#string', status: 'SUCCESS' }
    And match response.newBalance == expectedBalance

    * def balancePath = routes.accountBalance(accountId)
    Given path balancePath
    When method get
    Then status 200
    And match response.balance == expectedBalance
    And match response.currency == accountData.currency

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
