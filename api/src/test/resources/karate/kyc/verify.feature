Feature: KYC API @BANK-211

  Background:
    * call read('classpath:karate/common/setup.feature')
    * def routes = call read('classpath:karate/common/routes.js')
    * url baseUrl

  Scenario Outline: Verify customer identity for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    * def kyc = scenario.kyc

    Given path routes.onboarding
    And request { firstName: '#(user.firstName)', lastName: '#(user.lastName)', email: '#(user.email)', phone: '#(user.phone)', password: '#(user.password)' }
    When method post
    Then status 201
    * def customerId = response.customerId

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
    And match response == { customerId: '#(customerId)', kycStatus: 'VERIFIED', message: 'KYC verified' }

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
