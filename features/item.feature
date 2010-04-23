Feature: Manage items
  In order to create and manage items
  I must login select the organisation
  and create a new oranisation

  Scenario Outline:
    Given I create and go to login page
    And I create data
    And Iam on "/users/sign_out"
    Then Iam on "/users/sign_in"
    Then I fill my email and password
 

  Examples:
    |name|description|
