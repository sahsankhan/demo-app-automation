@ignore
Feature: Shared API background

  Scenario:
    Given url baseUrl
    And path 'api', apiVersion, 'test', 'reset'
    When method post
    Then status 200
