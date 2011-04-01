Feature: Show search columns

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
    When I check "Speakers" within "#show_columns"
    And I check "Senteances" within "#show_columns"
    And I uncheck "Properties" within "#show_columns"
    And I uncheck "Value" within "#show_columns"
    Then I press "Search"
    Then I should see "Speaker 1"
    And I should see "Speaker 2"
    And I should see "Sentence 1"
    And I should see "Sentence 2"
    And I should not see "Property"
    And I should not see "Properties"
    And I should not see "Value"
    And I should not see "pval"
    And I should not see "Eastern"

  Scenario: Choose property only
  Scenario: Choose value pair only