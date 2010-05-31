Feature: Manage contacts
  In order to create and manage contacts
  I must login select the organisation
  and create a new oranisation
  and Create contacts

  Scenario Outline:
    Given I create one organisation ecuanime
    Then I login
    Then Iam on "/organisations"
    And I click the ecuanime link
    Then Iam on "/contacts"
    And I click the Nuevo link
    Then I fill the contact form with <name>, <email>, <address>, <phone>, <mobile>, <tax_id>
    And I should see contact with <name>, <email>, <address>, <phone>, <mobile>, <tax_id>
    And I click the Edit link
    Then I change the contact email with boris@example.com
    And I should see contact email boris@example.com

 

  Examples:
    |name         |email               |address        |phone  |mobile  |tax_id |
    |Boris Barroso|boriscyber@gmail.com|Mallasa calle 4|2745620|70681101|3376951|
