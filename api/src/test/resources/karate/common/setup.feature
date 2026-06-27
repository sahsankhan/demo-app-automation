@ignore
Feature: Shared API background

  Scenario:
    * def routes = call read('classpath:karate/common/routes.js')
    Given url baseUrl
    And path routes.reset
    When method post
    Then status 200
