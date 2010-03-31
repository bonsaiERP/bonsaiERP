Feature: Manage taxes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new tax
    Given I am on the new tax page
    When I fill in "Name" with "name 1"
    And I fill in "Abbreviation" with "abbreviation 1"
    And I fill in "Rate" with "rate 1"
    And I fill in "Organisation" with "organisation 1"
    And I press "Create"
    Then I should see "name 1"
    And I should see "abbreviation 1"
    And I should see "rate 1"
    And I should see "organisation 1"

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
  Scenario: Delete tax
    Given the following taxes:
      |name|abbreviation|rate|organisation|
      |name 1|abbreviation 1|rate 1|organisation 1|
      |name 2|abbreviation 2|rate 2|organisation 2|
      |name 3|abbreviation 3|rate 3|organisation 3|
      |name 4|abbreviation 4|rate 4|organisation 4|
    When I delete the 3rd tax
    Then I should see the following taxes:
      |Name|Abbreviation|Rate|Organisation|
      |name 1|abbreviation 1|rate 1|organisation 1|
      |name 2|abbreviation 2|rate 2|organisation 2|
      |name 4|abbreviation 4|rate 4|organisation 4|
