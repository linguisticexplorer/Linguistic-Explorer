Feature: Search with Any

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"

  Scenario: Visitor searches any property
    And the following properties:
    | name            | depth | group                 |
    | Object Subject  | 0     | Syntactic Structures  |
    | Subject Verb    | 0     | Syntactic Structures  |
    | Verb Object     | 0     | Syntactic Structures  |
    When I go to the new search page
    And I check "Include property"
    And I uncheck "Include language"
    And I select "Object Subject" from "Properties"
    And I press "Search"
    Then I should see "Results"
    And I should see "Object Subject"
    And I should not see "Subject Verb"
    And I should not see "Verb Object"

  Scenario: Visitor allows all properties
    And the following properties:
    | name            | depth | group                 |
    | Object Subject  | 0     | Syntactic Structures  |
    | Subject Verb    | 0     | Syntactic Structures  |
    | Verb Object     | 0     | Syntactic Structures  |
    When I go to the new search page
    And I check "Include property"
    And I uncheck "Include language"
    And I press "Search"
    Then I should see "Results"
    And I should see "Object Subject"
    And I should see "Subject Verb"
    And I should see "Verb Object"

