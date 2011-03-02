Feature: Creating a Ling

  Background:
    Given the group "Syntactic Structures"

  Scenario: Visitor can create a ling
    Given I am a visitor
    And I go to the group Syntactic Structures
    And I follow the "Ling" model link for the group "Syntactic Structures" with depth "0"
    When I follow "New Ling"
    Then I should see "New ling"
    When I fill in "English" for "Name"
    And I fill in "0" for "Depth"
    And I press "Create Ling"
    Then I should see "Ling was successfully created"
    And I should see "English"
