Feature: Search with Cross

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
    | Property 1    | Speaker 3   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 1   | Western   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 3    | Sentence 3  | noun      | Linguistic  | 1     |
    | Property 4    | Sentence 1  | noun      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |

  Scenario: Visitor searches cross Demographic Properties from two
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I press "Show results"
    Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 1      | Eastern          | Property 2      | Western          |   1   |
    And I should not see "Speaker 2"
    And I should not see "Property 3"
    And I should not see "Sentence 2"
    And I should not see "verb"

  Scenario: Visitor searches cross Demographic Properties from two and see languages
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I press "Show results"
    Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 1      | Eastern          | Property 2      | Western          |   1   |
    And I should not see "Speaker 2"
    And I should not see "Property 3"
    And I should not see "Sentence 2"
    And I should not see "verb"
    And I follow "1"
    And I should see "Ling"
    Then I should see 1 ling in the row

  Scenario: Visitor searches cross Linguistic Properties from two
    When I go to the Syntactic Structures search page
    And I select "Property 3" from "Linguistic Properties"
    And I select "Property 4" from "Linguistic Properties"
    And I choose "Cross" within "#linguistic_properties"
    And I press "Show results"
    Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | verb            | Property 4       | noun             |   1   |
    | Property 3      | noun            | Property 4       | noun             |   0   |
    And I should not see "Speaker 2"
    And I should not see "Property 1"
    And I should not see "Sentence 2"
    And I should not see "Eastern"

  Scenario: Visitor searches cross Linguistic Properties from two and see languages
    When I go to the Syntactic Structures search page
    And I select "Property 3" from "Linguistic Properties"
    And I select "Property 4" from "Linguistic Properties"
    And I choose "Cross" within "#linguistic_properties"
    And I press "Show results"
   Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | verb            | Property 4       | noun             |   1   |
    | Property 3      | noun            | Property 4       | noun             |   0   |
    And I should not see "Speaker 2"
    And I should not see "Property 1"
    And I should not see "Sentence 2"
    And I should not see "Eastern"
    And I follow "1"
    And I should see "Ling"
    Then I should see 1 ling in the row

   Scenario: Visitor searches cross both Demographic and Linguistic Properties from two each
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I select "Property 3" from "Linguistic Properties"
    And I select "Property 4" from "Linguistic Properties"
    And I choose "Cross" within "#linguistic_properties"
    And I press "Show results"
    Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 1      | Eastern          | Property 2      | Western          |   1   |
    And I should not see "Speaker 2"
    And I should not see "Property 3"
    And I should not see "Sentence 2"
    And I should not see "verb"

  Scenario: Visitor searches cross Demographic Properties from two, but select some value pairs
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I select "Property 1: Eastern" from "Demographic Value Pairs"
    And I press "Show results"
    Then I should see the following Cross search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 1      | Eastern          | Property 2      | Western          |   1   |
    And I should not see "Speaker 2"
    And I should not see "Property 3"
    And I should not see "Sentence 2"
    And I should not see "verb"

