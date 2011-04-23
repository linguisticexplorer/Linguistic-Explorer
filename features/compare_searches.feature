Feature: Compare searches

  Background:

    Given I am signed in as "bob@example.com"
    And the group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    And the following results for the group search "First search":
    | parent ling | parent property | parent value  | child value | child ling  | child property |
    | Speaker 1   | Property 1      | parent val 1  | child val 1 | Sentence 1  | Property 11    |
    | Speaker 2   | Property 2      | parent val 2  | child val 2 | Sentence 2  | Property 12    |
    And the following results for the group search "Second search":
    | parent ling | parent property | parent value  | child value | child ling  | child property |
    | Speaker 1   | Property 3      | parent val 3  | child val 3 | Sentence 3  | Property 13    |
    | Speaker 2   | Property 2      | parent val 2  | child val 2 | Sentence 2  | Property 12    |
    When I go to the group Syntactic Structures
    And I follow "History"

  Scenario: Union two saved searches
    Then I should see "Perform"
    When I select "union" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see the following grouped search results:
    | parent ling | parent property | child ling  | child property |
    | Speaker 1   | Property 1      | Sentence 1  | Property 11    |
    | Speaker 1   | Property 1      | Sentence 3  | Property 13    |
    | Speaker 1   | Property 3      | Sentence 3  | Property 13    |
    | Speaker 1   | Property 3      | Sentence 1  | Property 11    |
    | Speaker 2   | Property 2      | Sentence 2  | Property 12    |

  Scenario: Intersect two saved searches
  Scenario: Difference of two saved searches
  Scenario: Difference of saved searches with parent recovery
