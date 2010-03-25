Feature: Manage organisations
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new organisation
    Given I am on the new organisation page
    When I fill in "User" with "user 1"
    And I fill in "Country" with "country 1"
    And I fill in "Name" with "name 1"
    And I fill in "Address" with "address 1"
    And I fill in "Address alt" with "address_alt 1"
    And I fill in "Phone" with "phone 1"
    And I fill in "Phone alt" with "phone_alt 1"
    And I fill in "Mobile" with "mobile 1"
    And I fill in "Email" with "email 1"
    And I fill in "Website" with "website 1"
    And I press "Create"
    Then I should see "user 1"
    And I should see "country 1"
    And I should see "name 1"
    And I should see "address 1"
    And I should see "address_alt 1"
    And I should see "phone 1"
    And I should see "phone_alt 1"
    And I should see "mobile 1"
    And I should see "email 1"
    And I should see "website 1"

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
  Scenario: Delete organisation
    Given the following organisations:
      |user|country|name|address|address_alt|phone|phone_alt|mobile|email|website|
      |user 1|country 1|name 1|address 1|address_alt 1|phone 1|phone_alt 1|mobile 1|email 1|website 1|
      |user 2|country 2|name 2|address 2|address_alt 2|phone 2|phone_alt 2|mobile 2|email 2|website 2|
      |user 3|country 3|name 3|address 3|address_alt 3|phone 3|phone_alt 3|mobile 3|email 3|website 3|
      |user 4|country 4|name 4|address 4|address_alt 4|phone 4|phone_alt 4|mobile 4|email 4|website 4|
    When I delete the 3rd organisation
    Then I should see the following organisations:
      |User|Country|Name|Address|Address alt|Phone|Phone alt|Mobile|Email|Website|
      |user 1|country 1|name 1|address 1|address_alt 1|phone 1|phone_alt 1|mobile 1|email 1|website 1|
      |user 2|country 2|name 2|address 2|address_alt 2|phone 2|phone_alt 2|mobile 2|email 2|website 2|
      |user 4|country 4|name 4|address 4|address_alt 4|phone 4|phone_alt 4|mobile 4|email 4|website 4|
