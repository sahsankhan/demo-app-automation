Feature: Onboarding API @BANK-111

  Background:
    * call read('classpath:karate/common/setup.feature')
    * url baseUrl

  Scenario Outline: Register customer via API for <userId>
    * def scenario = call read('classpath:karate/common/load-scenario.js') { userId: '#(userId)' }
    * def user = scenario.user
    Given path 'api', apiVersion, 'onboarding', 'register'
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
    And match response contains { customerId: '#string', status: 'REGISTERED', email: '#(user.email)' }
    And match response.message == 'Registration successful'

  Examples:
    | userId           |
    | user-standard-us |
    | user-premium-uk  |
    | user-savings-ca  |
