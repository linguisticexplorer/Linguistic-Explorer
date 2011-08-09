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
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Question      | Property 3    | verb      | child   |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Partial keyword search on ling depth 0
    When I fill in "Language Keywords" with "glish"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Question      | Property 3    | verb      | child   |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Keyword search on ling depth 1
    When I fill in "Sentence Keywords" with "Quest"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Question      | Property 3    | verb      | child   |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Keyword search on property
    When I fill in "Demographic Keywords" with "Property 1"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Question      | Property 3    | verb      | child   |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Partial keyword search on property, all results
    When I fill in "Demographic Keywords" with "Property"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Spanish       | Property 2    | Western   | parent  |
    | Question      | Property 3    | verb      | child   |
    | Answer        | Property 4    | noun      | child   |

  Scenario: Partial keyword search on property, one result
    When I fill in "Demographic Keywords" with "erty 1"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |


  Scenario: Combined keywords search on ling depth 0 and depth 1
    When I fill in "Language Keywords" with "ish"
    When I fill in "Sentence Keywords" with "Quest"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Properties    | Value     | depth   |
    | English       | Property 1    | Eastern   | parent  |
    | Question      | Property 3    | verb      | child   |
    And I should not see "Spanish"
    And I should not see "Western"
    And I should not see "Answer"
    And I should not see "noun"

  Scenario: Wrong keyword search, no result
    When I fill in "Language Keywords" with "ash"
    And I press "Show results"
    Then I should see no search result rows

  Scenario: Wrong keyword search on ling depth 0, Right keyword on ling depth 1, no results
    When I fill in "Language Keywords" with "ash"
    When I fill in "Sentence Keywords" with "Quest"
    And I press "Show results"
    Then I should see no search result rows

  Scenario: Right keyword search on ling depth 0, Wrong (but existing in DB) keyword on ling depth 1, no results
    When I fill in "Language Keywords" with "Eng"
    When I fill in "Sentence Keywords" with "Ans"
    And I press "Show results"
    Then I should see no search result rows

  Scenario: Right keyword search on ling depth 0, Wrong keyword on ling depth 1, no results
    When I fill in "Language Keywords" with "Eng"
    When I fill in "Sentence Keywords" with "Ruest"
    And I press "Show results"
    Then I should see no search result rows