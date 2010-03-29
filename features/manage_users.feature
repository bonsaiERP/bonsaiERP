Feature: Manage users
  In order to create users
  I should be able to create
  the each with email confirmation
  
  
  Scenario Outline: Register new user
    Given Iam on "/users/new" page
    And I insert data with <first_name>, <last_name>, <email>, <password>
    And I should see a page with <first_name>
    And I confirm my subcription in "/users/confirmation"
    Then I see "http://www.example.com/"
    And Iam on "/users/sign_out"
    And Iam on "/users/sign_in"
    And fill login data with <email>, <password>
    Then I see "http://www.example.com/"


  # interpreter.
  #
  Examples:
    |first_name|last_name|email|password|password_confirmation|
    |Boris| Barroso | boriscyber@gmail.com|demo123|demo123|

