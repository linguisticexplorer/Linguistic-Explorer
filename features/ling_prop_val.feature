Feature: Search Ling Prop Value Pair
  
  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following lings and properties:
    | name        | property_name     | ling_prop_val   | depth | group                 |
    | English     | Adjective Noun    | yes             | 0     | Syntactic Structures  |
    | Spanish     | Adjective Noun    | no              | 0     | Syntactic Structures  |
    | English     | Adjective Degree  | yes             | 0     | Syntactic Structures  |
    | German      | Adjective Degree  | no              | 0     | Syntactic Structures  |
    | German      | Degree Adjective  | yes             | 0     | Syntactic Structures  |
    | Spanish     | Degree Adjective  | no              | 0     | Syntactic Structures  |

    # Ling[] Prop[] Val[]
    # selector for ling
    # selector for prop
    # selector for val
    # choosing any
    # choosing all

  Scenario: Visitor selects one value pair
    When I go to the new search page
    And I select "Adjective Noun: yes" from "Property Value"
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
    When I go to the new search page
    And I select "Adjective Noun: yes" from "Property Value"
    And I select "Degree Adjective: no" from "Property Value"
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
    