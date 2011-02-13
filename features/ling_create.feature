Feature: Creating a Ling
  
  Scenario: Visitor can create a ling
    Given I am a visitor
    When I go to the new ling page
    Then I should see "New ling"
    When I fill in "English" for "Name"
    And I fill in "0" for "Depth"
    And I press "Create Ling"
    Then I should see "Ling was successfully created"
    And I should see "English"
