Feature: Search with Any

  Background:
    Given I am a visitor

  Scenario: Visitor searches any language
    And the following properties:
    | name            |
    | Object Subject  |
    | Subject Verb    |
    | Verb Object     |
    When I go to the new search page
    And I check "Include property"
    And I select "Object Subject" from "Properties"
    And I press "Search"
    Then I should see "Results"
    And I should see "Object Subject"
    And I should not see "Subject Verb"
    And I should not see "Verb Object"

