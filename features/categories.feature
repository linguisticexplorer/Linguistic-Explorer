Feature: Search Ling Prop Value Pair by Categories

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |
    When I go to the Syntactic Structures search page

  Scenario: View search form with depth and categories
    Then the select menu for "Languages 0" should contain the following:
    | option        |
    | Speaker 1     |
    | Speaker 2     |
    And the select menu for "Languages 1" should contain the following:
    | option        |
    | Sentence 1    |
    | Sentence 2    |
    And the select menu for "Demographic Properties" should contain the following:
    | option        |
    | Property 1    |
    | Property 2    |
    And the select menu for "Linguistic Properties" should contain the following:
    | option        |
    | Property 3    |
    | Property 4    |
    And the select menu for "Demographic Value Pairs" should contain the following:
    | option                |
    | Property 1: Eastern   |
    | Property 2: Western   |
    And the select menu for "Demographic Value Pairs" should not contain the following:
    | option            |
    | Property 3: verb  |
    | Property 4: noun  |
    And the select menu for "Linguistic Value Pairs" should contain the following:
    | option            |
    | Property 3: verb  |
    | Property 4: noun  |

  Scenario: Basic depth search
    When I select "Sentence 1" from "Languages 1"
    And I press "Search"
    Then I should see the following search results:
    | Languages     | Properties  | Value     |
    | Speaker 1     | Property 1  | Eastern   |
    | Sentence 1    | Property 3  | verb      |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"

  Scenario: Basic categorized property search
    When I select "Property 3" from "Linguistic Properties"
    And I press "Search"
    Then I should see the following search results:
    | Languages     | Properties  | Value     |
    | Speaker 1     | Property 1  | Eastern   |
    | Sentence 1    | Property 3  | verb      |
    And I should not see "Property 2"
    And I should not see "Property 4"

  Scenario: Basic categorized property search
    When I select "Property 3: verb" from "Linguistic Value Pairs"
    And I press "Search"
    Then I should see "Sentence 1"
    And I should see "Property 3"
    And I should see "verb"
    And I should not see "noun"