Feature: Show simple search columns

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | PropVal 1 | Demographic | 0     |
    | Property 2    | Speaker 2   | PropVal 2 | Demographic | 0     |
    | Property 3    | Sentence 1  | PropVal 3 | Linguistic  | 1     |
    | Property 4    | Sentence 2  | PropVal 4 | Linguistic  | 1     |
    When I go to the Syntactic Structures search page

  Scenario: Choose all

  Scenario: Choose lings only
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    Then I press "Show results"
    Then I should see the following search results:
    | Lings         | depth    |
    | Speaker 1     | parent   |
    | Speaker 2     | parent   |
    | Sentence 1    | child    |
    | Sentence 2    | child    |
    And I should not see "Property" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"

  Scenario: Choose ling depth 0 only
    When I check "Speakers" within "#show_columns"
    And I uncheck "Sentences" within "#show_columns"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    Then I press "Show results"
    Then I should see the following search results:
    | Lings         |
    | Speaker 1     |
    | Speaker 2     |
    And I should not see "Sentence 1" within "#search_results"
    And I should not see "Sentence 2" within "#search_results"
    And I should not see "Property" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"

  Scenario: Choose property
    When I check "Speakers" within "#show_columns"
    And I check "Sentences" within "#show_columns"
    And I check "Properties" within "#show_columns"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    Then I press "Show results"
    Then I should see the following search results:
    | Lings         | Property     | depth    |
    | Speaker 1     | Property 1   | parent   |
    | Speaker 2     | Property 2   | parent   |
    | Sentence 1    | Property 3  | child    |
    | Sentence 2    | Property 4  | child    |
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"

  Scenario: Choose value pair too
    When I check "Speakers" within "#show_columns"
    And I check "Sentences" within "#show_columns"
    And I uncheck "Properties" within "#show_columns"
    And I check "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    Then I press "Show results"
    Then I should see the following search results:
    | Lings         | Property     | PropVal    | depth    |
    | Speaker 1     | Property 1   | PropVal 1  | parent   |
    | Speaker 2     | Property 2   | PropVal 2  | parent   |
    | Sentence 1    | Property 3   | PropVal 3  | child   |
    | Sentence 2    | Property 4   | PropVal 4  | child   |