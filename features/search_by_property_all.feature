Feature: Search with All

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Speaker 3   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    | Sentence 3  | Speaker 3   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 1   | Western   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 1    | Speaker 3   | Eastern   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 4    | Sentence 1  | noun      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |
    | Property 3    | Sentence 3  | noun      | Linguistic  | 1     |

  Scenario: Visitor searches all properties from two
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "All" within "#demographic_properties"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties        | Value     | depth   |
    | Speaker 1     | Property 1        | Eastern   | parent  |
    | Speaker 1     | Property 2        | Western   | parent  |
    | Sentence 1    | Property 3        | verb      | child   |
    | Sentence 1    | Property 4        | noun      | child   |
    And I should not see "Speaker 2"
    And I should not see "Speaker 3"
    And I should not see "Sentence 2"
    And I should not see "Sentence 3"