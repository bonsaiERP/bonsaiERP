Feature: Manage organisations
  In order to manage organisations
  I must login and check create a
  new organisation

  Scenario Outline:
    Given I create and go to the login page
    Then Iam on "/organisations/new"
    And I fill data with <name>, <country_id>, <address>, <phone>



  Examples:
    |name|country_id|address|phone|
    |ecuanime|1|Mallasa|2745620|
