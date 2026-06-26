@ignore
Feature: Reset mock API state between scenarios

  Scenario:
    Given url baseUrl
    And path 'api', apiVersion, 'test', 'reset'
    When method post
    Then status 200
    And match response.status == 'RESET'