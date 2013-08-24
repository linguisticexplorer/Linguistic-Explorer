Feature: Typeahead

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
    And the group "Test"
    And the group has a maximum depth of 0
    And the following "Test" lings:
    | name        | depth |
    | Afrikaans   | 0     |
    | Spanish     | 0     |
    | German      | 0     |
    | Italian     | 0     |
    | French      | 0     |
    | Bellinzonese| 0     |


  @javascript
  Scenario: Visitor searches a language from the group page and languages of all depths are available
    When I go to the home page
    Then I wait "2"
    Then I should see "" within "#auto_1"
    When I fill in "auto_1" with "b"
    Then I should see "Bellinzonese" within ".typeahead"
    When I fill in "auto_1" with "afr"
    Then I should see "Afrikaans" within ".typeahead"
    When I follow "Afrikaans"
    Then I should see "Ling Afrikaans"
    When I go to the home page
    Then I should see "Test" within "#tabs"
    Then I follow "Test" within "#tabs"
    Then I should see "" within "#auto_2"
    When I fill in "auto_2" with "b"
    Then I should see "Bellinzonese" within ".typeahead"
    When I fill in "auto_2" with "afr"
    Then I should see "Afrikaans" within ".typeahead"
    When I follow "Afrikaans"
    Then I should see "Ling Afrikaans"


  @javascript
  Scenario: Visitor searches a language from the group page and languages of all depths are available
    When I go to the group Syntactic Structures
    Then I should see "" within "#auto_group"
    When I fill in "auto_group" with "b"
    Then I should see "Bellinzonese" within ".typeahead"
    When I fill in "auto_group" with "afr"
    Then I should see "Afrikaans" within ".typeahead"
    When I follow "Afrikaans"
    Then I should see "Ling Afrikaans"

  @javascript
  Scenario: Visitor searches a language from the group page and languages of all depths are available
    When I go to the group Syntactic Structures
    Then I should see "" within "#auto_group"
    When I fill in "auto_group" with "b"
    Then I should see "Bellinzonese" within ".typeahead"
    When I fill in "auto_group" with "afr"
    Then I should see "Afrikaans" within ".typeahead"
    When I follow "Afrikaans"
    Then I should see "Ling Afrikaans"

  @javascript
  Scenario: Visitor goes to Ling page and searches a language and only languages with the right depth are searchable
    When I go to the group Syntactic Structures
    And I follow "Lings"
    Then I should see "" within "#auto_lang"
    When I fill in "auto_lang" with "b"
    Then I should not see "Bellinzonese"
    When I fill in "auto_lang" with "s"
    Then I should see "Spanish" within ".typeahead"
    When I follow "Spanish"
    Then I should see "Ling Spanish"

  @javascript
  Scenario: Visitor goes to Property page and searches a property
    When I go to the group Syntactic Structures
    And I follow "Properties"
    #sometimes fails due to the time needed to load typeahead dictionary
    Then I wait "2"
    Then I should see "" within "#auto_prop"
    When I fill in "auto_prop" with "degree"
    Then I should see "Degree Adjective" within ".typeahead"
    When I follow "Degree Adjective"
    Then I should see "Property Degree Adjective"

