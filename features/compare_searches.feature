Feature: Compare searches

  Background:

    Given I am signed in as "bob@example.com"
    And the group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |

  Scenario: Intersect two saved searches
  Scenario: Union two saved searches
  Scenario: Difference of two saved searches
  Scenario: Difference of saved searches with parent recovery
