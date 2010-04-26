Feature: Manage items
  In order to create and manage items
  I must login select the organisation
  and create a new oranisation

  Scenario Outline:
    Given I create one organisation ecuanime
    Then I login
    Then Iam on "/organisations"
    And I click the ecuanime link
    Then Iam on "/items"
    And I click the New link
    Then I fill the item form with <name>, <unit>, <product>, <stockable>
    And I should see item with <name>, <unit>, <product>, <stockable>


 

  Examples:
    |name             |unit   |product|stockable|
    |Web site creation|service|true| false|
    |Personal computer|unit|true| false|
    |Inventory cost|hour|false| false|
