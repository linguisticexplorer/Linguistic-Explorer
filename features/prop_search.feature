Feature: Search with Any

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following lings and properties:
    | name        | property_name     | property_value  | depth | group                 |
    | English     | Adjective Noun    | yes             | 0     | Syntactic Structures  |
    | English     | Adjective Degree  | yes             | 0     | Syntactic Structures  |
    | Spanish     | Adjective Noun    | yes             | 0     | Syntactic Structures  |
    | German      | Degree Adjective  | yes             | 0     | Syntactic Structures  |

  Scenario: Visitor allows all properties
    When I go to the new search page
    And I press "Search"
    Then I should see "Results"
    And I should see "Adjective Noun"
    And I should see "Adjective Degree"
    And I should see "Degree Adjective"

  Scenario: Visitor searches any property
    When I go to the new search page
    And I select "Adjective Noun" from "Properties"
    And I press "Search"
    Then I should see "Results"
    And I should see "Adjective Noun"
    And I should not see "Adjective Degree"
    And I should not see "Degree Adjective"

