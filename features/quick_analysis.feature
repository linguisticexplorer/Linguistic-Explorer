Feature: Analysis

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group has a maximum depth of 1
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | Afrikaans   | 0     |
    | Spanish     | 0     |
    | German      | 0     |
    | Italian     | 0     |
    | French      | 0     |
    | Bellinzonese| 1     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | category | depth |
    | Adjective Noun    | Afrikaans   | yes         | Grammar  | 0     |
    | Adjective Degree  | Afrikaans   | yes         | Grammar  | 0     |
    | Degree Adjective  | Afrikaans   | yes         | Grammar  | 0     |
    | Degree Adjective  | German      | yes         | Grammar  | 0     |
    | Degree Adjective  | Spanish     | no          | Grammar  | 0     |
    | Demonstrative Noun| Afrikaans   | no          | Grammar  | 0     |
    | Noun Demonstrative| Afrikaans   | no          | Grammar  | 0     |
    | Degree Adjective  | Italian     | yes         | Grammar  | 0     |
    | Degree Adjective  | French      | yes         | Grammar  | 0     |
    | Degree Adjective  | Bellinzonese| yes         | Grammar  | 1     |

    And I go to the group Syntactic Structures
    And I follow "Lings"
    And I follow "Afrikaans"
    Then I should see "Ling Afrikaans"

  @selenium
  Scenario: Visitor should be able to map a language 
    Then I should see "Map" within "#compare-buttons"
    When I follow "Map"
    Then I access the new tab
    Then I should see "Lings in the Selection"

