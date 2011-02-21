Feature: Search Ling Prop Value Pair
  
  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    | Spanish     | 0     |
    | German      | 0     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | category | depth |
    | Adjective Noun    | English     | yes         | Grammar  | 0     |
    | Adjective Noun    | Spanish     | no          | Grammar  | 0     |
    | Adjective Degree  | English     | yes         | Grammar  | 0     |
    | Adjective Degree  | German      | no          | Grammar  | 0     |
    | Degree Adjective  | German      | yes         | Grammar  | 0     |
    | Degree Adjective  | Spanish     | no          | Grammar  | 0     |

    # Ling[] Prop[] Val[]
    # selector for ling
    # selector for prop
    # selector for val
    # choosing any
    # choosing all

  Scenario: Visitor selects one value pair
    When I go to the Syntactic Structures search page
    And I select "Adjective Noun: yes" from "Grammar Value Pairs"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should see "Adjective Noun"
    And I should see "yes"
    And I should not see "German"
    And I should not see "Spanish"
    And I should not see "Adjective Degree"
    And I should not see "Degree Adjective"
    And I should not see "no"
  
  Scenario: Visitor selects two value pairs
    When I go to the Syntactic Structures search page
    And I select "Adjective Noun: yes" from "Grammar Value Pairs"
    And I select "Degree Adjective: no" from "Grammar Value Pairs"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should see "Spanish"
    And I should see "Adjective Noun"
    And I should see "Degree Adjective"
    And I should see "yes"
    And I should see "no"
    And I should not see "German"
    And I should not see "Adjective Degree"
    