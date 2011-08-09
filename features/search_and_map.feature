Feature: Map results

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Language    | Sentence    |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | English     |             | 0     |
    | Spanish     |             | 0     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | English     | Eastern   | Demographic | 0     |
    | Property 2    | Spanish     | Western   | Demographic | 0     |
    When I go to the Syntactic Structures search page

  Scenario: Link Map It in the results page
    When I fill in "Language Keywords" with "Eng"
    And I press "Show results"
    Then I should see "Map It"

  Scenario: Click to Map It
