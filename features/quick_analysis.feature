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
    | Adjective Noun    | Spanish     | yes         | Grammar  | 0     |
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
    Then I should see "Ling : Afrikaans"
  
  @wip
  @javascript
  Scenario: Visitor should be able to map a language 
    Then I should see "Map" within "#compare-buttons"
    When I follow "Map"
    # Then a new window "Search Results" will open
    Then I access the new tab and should see "Lings in the Selection"
    # Then I should see "Lings in the Selection"
  
  @wip
  @javascript
  Scenario: Visitor should be able to add and delete languages of the same depth to analyse
    # When I fill in "auto_compare" with "s"
    When I search in the "auto_compare" field with "spa"
    Then I should see "Spanish" in the "auto_compare"
    Then I see the Javascript console
    # Then I follow "Spanish" within ".typeahead"
    Then I add "Spanish" to the list
    Then I should see "Spanish" within "#selected-lings"
    Then I follow "clear all" within "#languages-container"
    Then I should not see "Spanish" within "#selected-lings"
    # When I fill in "auto_compare" with "b"
    When I search in the "auto_compare" field with "bel"
    Then I should not see "Bellinzonese"
  
  @wip
  @javascript
  Scenario: Visitor should be able to perform quick analysis on languages 
    # When I fill in "auto_compare" with "s"
    When I search in the "auto_compare" field with "spa"
    Then I should see "Spanish" within ".typeahead"
    Then I add "Spanish" to the list
    Then I follow "Compare Properties" within "#compare-buttons"
    # Then a new window "Search Results" will open
    Then I access the new tab and should see "Properties in Common" 
    # Then I should see "Properties in Common"
    # Then I access the first tab
    Then I follow "Similarity Tree" within "#compare-buttons"
    # Then a new window "Search Results" will open
    Then I access the new tab and should see "Search Results"
    # Then I should see "Search Results"
    # Then I access the first tab
    Then I follow "Radial Tree" within "#compare-buttons"
    # Then a new window "Search Results" will open
    Then I access the new tab and should see "Search Results"
    # Then I should see "Search Results" 
