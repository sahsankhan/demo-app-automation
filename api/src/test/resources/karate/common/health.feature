@ignore
Feature: Shared API helpers

  Scenario: Health check
    Given url baseUrl
    And path 'api', apiVersion, 'health'
    When method get
    Then status 200
    And match response.status == 'UP'
