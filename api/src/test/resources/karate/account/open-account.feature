Feature: Account API @BANK-311

  Background:
    * call read('classpath:karate/common/setup.feature')
    * url baseUrl

  Scenario Outline: Open account after KYC for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    * def kyc = scenario.kyc
    * def accountData = scenario.account

    Given path 'api', apiVersion, 'onboarding', 'register'
    And request { firstName: '#(user.firstName)', lastName: '#(user.lastName)', email: '#(user.email)', phone: '#(user.phone)', password: '#(user.password)' }
    When method post
    Then status 201
    * def customerId = response.customerId

    Given path 'api', apiVersion, 'kyc', 'verify'
    And request { customerId: '#(customerId)', dateOfBirth: '#(kyc.dateOfBirth)', nationalId: '#(kyc.nationalId)', address: '#(kyc.address)', city: '#(kyc.city)', country: '#(kyc.country)', documentType: '#(kyc.documentType)' }
    When method post
    Then status 200

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
    And match response contains { accountId: '#string', accountNumber: '#string', status: 'OPEN' }
    And match response.balance == parseFloat(accountData.initialDeposit)
    And match response.currency == accountData.currency

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
