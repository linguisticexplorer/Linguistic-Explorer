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
    And I have a saved group search "Grammar sentences"
    When I go to my group searches page
    Then I should see "Grammar sentences"

