Feature: Search Lings for Compare Property

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  |
    | Languages   |
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    | German      | 0     |
    | Spanish     | 0     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | depth |
    | Adjective Noun    | English     | yes         | 0     |
    | Adjective Degree  | English     | yes         | 0     |
    | Adjective Noun    | Spanish     | yes         | 0     |
    | Degree Adjective  | German      | yes         | 0     |

  Scenario: Visitor selects one language
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "Spanish" from "Languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following Compare properties in common:
    | Property       | Common value |
    | Adjective Noun | yes          |
    Then I should see the following Compare properties not in common:
    | Property         | English value | Spanish value |
    | Adjective Degree | yes           |               |
