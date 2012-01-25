Feature: Search By Similarity Tree (R language)

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group has a maximum depth of 0
    And the following "Syntactic Structures" lings:
      | name        | depth |
      | English     | 0     |
      | Spanish     | 0     |
      | German      | 0     |
    And the following "Syntactic Structures" properties:
      | property name     | ling name   | prop val    | category | depth |
      | Adjective Noun    | English     | yes         | Grammar  | 0     |
      | Adjective Noun    | Spanish     | no          | Grammar  | 0     |
      | Adjective Degree  | English     | yes         | Grammar  | 0     |
      | Adjective Degree  | German      | no          | Grammar  | 0     |
      | Degree Adjective  | German      | yes         | Grammar  | 0     |
      | Degree Adjective  | Spanish     | no          | Grammar  | 0     |


  Scenario: Visitor searches Similarity Tree with all Properties and Lings
    When I go to the Syntactic Structures search page
    And I choose "Tree" within "#advanced_set"
    And I press "Show results"
    Then I should see the "SimilarityTree" draw