Feature: Manage users
  In order to create users
  I should be able to create
  the each with email confirmation
  
  
  Scenario: Register new user
    Given I am on the new user page
    When I fill in "user_first_name" with "first_name 1"
    And I fill in "user_last_name" with "last_name 1"
    And I fill in "user_email" with "email_1@example.com"
    And I fill in "user_phone" with "phone 1"
    And I fill in "user_mobile" with "mobile 1"
    And I fill in "user_website" with "website 1"
    And I fill in "user_description" with "description 1"
    And I fill in "user_password" with "password 1"
    And I fill in "user_password_confirmation" with "password 1"
    And I press "Create"
    Then I should see "first_name 1"
    And I should see "last_name 1"
    And I should see "email_1@example.com"
    And I should see "phone 1"
    And I should see "mobile 1"
    And I should see "website 1"
    And I should see "description 1"
    And I should see "password 1"

  # Rails generates Delete links that use Javascript to pop up a confirmation
  # dialog and then do a HTTP POST request (emulated DELETE request).
  #
  # Capybara must use Culerity or Selenium2 (webdriver) when pages rely on
  # Javascript events. Only Culerity supports confirmation dialogs.
  #
  # Since Culerity and Selenium2 has some overhead, Cucumber-Rails will detect 
  # the presence of Javascript behind Delete links and issue a DELETE request 
  # instead of a GET request.
  #
  # You can turn off this emulation by tagging your scenario with @selenium, 
  # @culerity, @celerity or @javascript. (See the Capybara documentation for 
  # details about those tags). If any of these tags are present, Cucumber-Rails
  # will also turn off transactions and clean the database with DatabaseCleaner 
  # after the scenario has finished. This is to prevent data from leaking into 
  # the next scenario.
  #
  # Another way to avoid Cucumber-Rails'' javascript emulation without using any
  # of the tags above is to modify your views to use <button> instead. You can
  # see how in http://github.com/jnicklas/capybara/issues#issue/12
  #
  # TODO: Verify with Rob what this means: The rack driver will detect the 
  # onclick javascript and emulate its behaviour without a real Javascript
  # interpreter.
  #
  Scenario: Delete user
    Given the following users:
      |first_name|last_name|email|phone|mobile|website|description|password|password_confirmation|
      |first_name 1|last_name 1|email_1@example.com|phone 1|mobile 1|website 1|description 1|password 1|password_confirmation 1|
      |first_name 2|last_name 2|email_2@example.com|phone 2|mobile 2|website 2|description 2|password 2|password_confirmation 2|
      |first_name 3|last_name 3|email_3@example.com|phone 3|mobile 3|website 3|description 3|password 3|password_confirmation 3|
      |first_name 4|last_name 4|email_4@example.com|phone 4|mobile 4|website 4|description 4|password 4|password_confirmation 4|

    When I delete the 3rd user
    Then I should see the following users:
      |First name|Last name|Email|Phone|Mobile|Website|Description|Password|Password confirmation|
      |first_name 1|last_name 1|email_1@example.com|phone 1|mobile 1|website 1|description 1|password 1|password_confirmation 1|
      |first_name 2|last_name 2|email_2@example.com|phone 2|mobile 2|website 2|description 2|password 2|password_confirmation 2|
      |first_name 4|last_name 4|email_4@example.com|phone 4|mobile 4|website 4|description 4|password 4|ord_confirmation 3|
