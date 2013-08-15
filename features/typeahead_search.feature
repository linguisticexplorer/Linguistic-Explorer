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

    And I go to the group Syntactic Structures

  @javascript
  Scenario: Visitor searches a language from the group page
    Then I should see "" within "#auto_group"
    When I fill in "auto_group" with "afr"
    Then I should see "Afrikaans" within ".typeahead"
    When I follow "Afrikaans"
    Then I should see "Ling Afrikaans"

  @javascript
  Scenario: Visitor goes to Ling page and searches a language
    When I follow "Lings"
    Then I should see "" within "#auto_lang"
    When I fill in "auto_lang" with "s"
    Then I should see "Spanish" within ".typeahead"
    When I follow "Spanish"
    Then I should see "Ling Spanish"

  @javascript
  Scenario: Visitor goes to Property page and searches a property
    When I follow "Properties"
    Then I should see "" within "#auto_prop"
    When I fill in "auto_prop" with "degree"
    Then I should see "Degree Adjective" within ".typeahead"
    When I follow "Degree Adjective"
    Then I should see "Property Degree Adjective"

