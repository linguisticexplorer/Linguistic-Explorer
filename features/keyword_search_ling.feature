Feature: Keyword Search on Ling

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Language    | Sentence    |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | English     |             | 0     |
    | Spanish     |             | 0     |
    | Question    | English     | 1     |
    | Answer      | Spanish     | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | English     | Eastern   | Demographic | 0     |
    | Property 2    | Spanish     | Western   | Demographic | 0     |
    | Property 3    | Question    | verb      | Linguistic  | 1     |
    | Property 4    | Answer      | noun      | Linguistic  | 1     |
    When I go to the Syntactic Structures search page

  Scenario: Keyword search on ling depth 0
    When I fill in "Language Keywords" with "Eng"
    And I press "Search"
    Then I should see the following search results:
    | Lings         | Properties    | Value     |
    | English       | Property 1    | Eastern   |
    | Question      | Property 3    | verb      |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Keyword search on ling depth 1
    When I fill in "Sentence Keywords" with "Quest"
    And I press "Search"
    Then I should see the following search results:
    | Lings         | Properties    | Value     |
    | English       | Property 1    | Eastern   |
    | Question      | Property 3    | verb      |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"
