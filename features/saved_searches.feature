Feature: Save searches

  Background:

    Given I am signed in as "bob@example.com"
    And the group "Syntactic Structures"
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
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |

  Scenario: View no saved searches
    When I go to my group searches page
    Then I should see "Syntactic Structures Searches"
    Then I should see "No saved searches for Syntactic Structures"

  Scenario: View a simple saved searches
    And I have a saved group search "My First Search"
    When I go to the Syntactic Structures search page
    When I follow "History"
    Then I should see "My First Search"

  Scenario: No link to search history if signed out
    And I have a saved group search "My First Search"
    When I go to the Syntactic Structures search page
    And I follow "Sign out"
    And I go to the Syntactic Structures search page
    Then I should not see "History"

  Scenario: Save search
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Search"
    Then I should see "Save search results"
    When I fill in "Name" with "My First Search"
    And I press "Save"
    Then I should see "Syntactic Structures Searches"
    And I should see "My First Search"

  Scenario: See results of saved search query
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Search"
    Then I should see "Save search results"
    When I fill in "Name" with "My First Search"
    And I press "Save"
    And I follow "Results"
    Then I should see the following search results:
    | Lings         | Properties  | Value     | depth   |
    | Speaker 1     | Property 1  | Eastern   | parent  |
    | Sentence 1    | Property 3  | verb      | child   |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"

  Scenario: Export search to csv
    When I go to the Syntactic Structures search page
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I check "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I check "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    And I press "Search"
    Then I should see "Save search results"
    When I fill in "Name" with "My First Search"
    And I press "Save"
    And I follow "Download CSV"
    Then the csv should contain the following rows
    | col_1     | col_2               | col_3           | col_4       |
    | Speaker   | Speaker Properties  | Speaker Values  | Sentence    |
    | Speaker 1 | Property 1          | Eastern         | Sentence 1  |

  Scenario: Regenerate results of saved search query
  Scenario: Delete saved query
  Scenario: Limit user to 25 searches
