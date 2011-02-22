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
    | Property 1    | Speaker 1   | yes       | Demographic | 0     |
    | Property 2    | Speaker 2   | no        | Demographic | 0     |
    | Property 3    | Sentence 1  | yes       | Phrasing    | 1     |
    | Property 4    | Sentence 2  | no        | Phrasing    | 1     |
    When I go to the Syntactic Structures search page

  Scenario: Search form with category
    Then the select menu for "Languages 0" should contain the following:
    | option        |
    | Speaker 1     |
    | Speaker 2     |
    And the select menu for "Languages 1" should contain the following:
    | option        |
    | Sentence 1    |
    | Sentence 2    |
    # And the select menu for "Demographic Properties" should contain the following:
    # | option        |
    # | Property 1    |
    # | Property 2    |
    # And the select menu for "Phrasing Properties" should contain the following:
    # | option        |
    # | Property 3    |
    # | Property 4    |
    And the select menu for "Demographic Value Pairs" should contain the following:
    | option            |
    | Property 1: yes   |
    | Property 2: no    |
    And the select menu for "Demographic Value Pairs" should not contain the following:
    | option            |
    | Property 3: yes   |
    | Property 4: no    |
    And the select menu for "Phrasing Value Pairs" should contain the following:
    | option            |
    | Property 3: yes   |
    | Property 4: no    |
