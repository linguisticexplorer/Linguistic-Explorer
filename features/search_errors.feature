Feature: Errors that happen during the Search

  Background:
    Given I am a visitor
    And the public group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  |
    | Languages   |
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | depth |
    | Adjective Noun    | English     | yes         | 0     |
    | Adjective Degree  | English     | yes         | 0     |
    | Degree Adjective  | English     | no          | 0     |
    | Demonstrative Noun| English     | yes         | 0     |
    | Noun Adjective    | English     | yes         | 0     |

  Scenario: Visitor try to cross-search too many properties, redirect to the Search page with notice
    When I go to the Syntactic Structures search page
    And I select "Adjective Noun" from "Grammar Properties"
    And I select "Adjective Degree" from "Grammar Properties"
    And I select "Degree Adjective" from "Grammar Properties"
    And I select "Demonstrative Noun" from "Grammar Properties"
    And I select "Noun Adjective" from "Grammar Properties"
    And I choose "Cross" within "#grammar_properties"
    And I press "Show results"
    Then I should be on the Syntactic Structures search page
    And I should see "An error occurred during the search"
    And I should see "Please select at least"

  Scenario: Visitor try to cross-search with one property, redirect to the Search page with notice
    When I go to the Syntactic Structures search page
    And I select "Adjective Noun" from "Grammar Properties"
    And I choose "Cross" within "#grammar_properties"
    And I press "Show results"
    Then I should be on the Syntactic Structures search page
    And I should see "An error occurred during the search"
    And I should see "Please select at least"