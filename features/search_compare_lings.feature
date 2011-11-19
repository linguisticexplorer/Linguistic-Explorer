Feature: Search Lings for Compare Property

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  |
    | Languages   |
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    | French      | 0     |
    | German      | 0     |
    | Spanish     | 0     |
    | Italian     | 0     |
    | Greek       | 0     |
    | Latin       | 0     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | depth |
    | Adjective Noun    | English     | yes         | 0     |
    | Adjective Degree  | English     | yes         | 0     |
    | Degree Adjective  | Spanish     | no          | 0     |
    | Possessor Noun    | Spanish     | no          | 0     |
    | Degree Adjective  | German      | yes         | 0     |
    | Possessor Noun    | German      | yes         | 0     |
    | Degree Adjective  | Italian     | no          | 0     |
    | Possessor Noun    | Italian     | no          | 0     |
    | Adjective Degree  | French      | yes         | 0     |
    | Adjective Degree  | Greek       | yes         | 0     |
    | Adjective Degree  | Latin       | yes         | 0     |

  Scenario: Visitor selects two languages
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "French" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 1 properties in common
    Then I should see 1 properties not in common

  Scenario: Visitor selects two languages with all properties not in common
    When I go to the Syntactic Structures search page
    And I select "German" from "Languages"
    And I select "Spanish" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 2 properties not in common

  Scenario: Visitor selects two languages with all properties in common
    When I go to the Syntactic Structures search page
    And I select "Italian" from "Languages"
    And I select "Spanish" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 2 properties in common

  Scenario: Visitor selects three languages
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "French" from "Languages"
    And I select "Latin" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 1 properties in common
    Then I should see 1 properties not in common

  Scenario: Visitor selects three languages with all properties not in common
    When I go to the Syntactic Structures search page
    And I select "German" from "Languages"
    And I select "Spanish" from "Languages"
    And I select "Italian" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 2 properties not in common

  Scenario: Visitor selects three languages with all properties in common
    When I go to the Syntactic Structures search page
    And I select "French" from "Languages"
    And I select "Greek" from "Languages"
    And I select "Latin" from "Languages"
    And I choose "Compare" within "#languages"
    And I press "Show results"
    Then I should see "Results"
    Then I should see 1 properties in common