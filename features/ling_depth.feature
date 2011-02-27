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

  Scenario: Retrieve speaker with demographic property
  # a sentence is retrieved only if the speaker of that sentence survives the demographic query
    When I select "Speaker 1" from "Languages 0"
    And I select "Speaker 2" from "Languages 0"
    And I select "Sentence 1" from "Languages 1"
    And I select "Sentence 2" from "Languages 1"
    And I select "Property 1" from "Demographic Properties"
    And I press "Search"
    Then I should see the following search results:
    | Languages     | Properties  | Value     |
    | Speaker 1     | Property 1  | Eastern   |
    | Sentence 1    | Property 3  | verb      |
    And I should not see "Sentence 2"

  Scenario: Retrieve sentence of speaker by linguistic property
  # a speaker is retrieved only if a sentence survives the linguistic query.
  And the following scenario is pending
    When I select "Speaker 1" from "Languages 0"
    And I select "Speaker 2" from "Languages 0"
    And I select "Sentence 1" from "Languages 1"
    And I select "Sentence 2" from "Languages 1"
    And I select "Property 3" from "Linguistic Properties"
    And I press "Search"
    Then I should see the following search results:
    | Languages     | Properties  | Value     |
    | Speaker 1     | Property 1  | Eastern   |
    | Sentence 1    | Property 3  | verb      |
    And I should not see "Speaker 2"
  