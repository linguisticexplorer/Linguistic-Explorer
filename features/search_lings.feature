Feature: Search Lings for Any Property

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  |
    | Languages   |
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    | German      | 0     |
    | Spanish     | 0     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | depth |
    | Adjective Noun    | English     | yes         | 0     |
    | Adjective Degree  | English     | yes         | 0     |
    | Adjective Noun    | Spanish     | yes         | 0     |
    | Degree Adjective  | German      | yes         | 0     |

  Scenario: Visitor selects one language
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I press "Show results"
    Then I should see "Results"
    And I should see "English"
    And I should not see "Spanish"
    And I should not see "German"

  Scenario: Visitor selects all languages
    When I go to the Syntactic Structures search page
    And I allow all languages
    And I press "Show results"
    Then I should see "Results"
    And I should see "English"
    And I should see "Spanish"
    And I should see "German"

  Scenario: Visitor selects one language, one property
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "Adjective Noun" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Noun    |
    And I should not see "Spanish"
    And I should not see "German"
    And I should not see "Adjective Degree"

  Scenario: Visitor selects multiple languages, one property
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "Spanish" from "Languages"
    And I select "German" from "Languages"
    And I select "Adjective Noun" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Noun    |
    | Spanish       | Adjective Noun    |
    And I should not see "German"
    And I should not see "Adjective Degree"

  Scenario: Visitor allows all languages, one property
    When I go to the Syntactic Structures search page
    And I allow all languages
    And I select "Adjective Noun" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Noun    |
    | Spanish       | Adjective Noun    |
    And I should not see "German"
    And I should not see "Adjective Degree"
    And I should not see "Degree Adjective"

  Scenario: Visitor allows one language, multiple properties, language has all properties chosen
    When I go to the Syntactic Structures search page
    And I select "English" from "Languages"
    And I select "Adjective Degree" from "Properties"
    And I select "Adjective Noun" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Degree  |
    | English        | Adjective Noun |
    And I should not see "Spanish"
    And I should not see "German"
    And I should not see "Degree Adjective"

    Scenario: Visitor allows one language, multiple properties, language has not all properties chosen
    When I go to the Syntactic Structures search page
    And I select "Spanish" from "Languages"
    And I select "Adjective Degree" from "Properties"
    And I select "Adjective Noun" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | Spanish        | Adjective Noun |
    And I should not see "English"
    And I should not see "German"
    And I should not see "Adjective Degree"
    And I should not see "Degree Adjective"

  Scenario: Visitor allows all languages, multiple properties
    When I go to the Syntactic Structures search page
    And I allow all languages
    And I select "Adjective Degree" from "Properties"
    And I select "Degree Adjective" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Degree  |
    | German        | Degree Adjective  |
    And I should not see "Spanish"
    And I should not see "Adjective Noun"

    Scenario: Visitor allows all languages, all properties
    When I go to the Syntactic Structures search page
    And I allow all languages
    And I allow all properties
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        |
    | English       | Adjective Degree  |
    | English       | Adjective Noun    |
    | Spanish       | Adjective Noun    |
    | German        | Degree Adjective  |

  Scenario: Scope search to group
    Given the group "Phones"
    And the following lings and properties:
    | name        | property_name | prop val  | depth | group   | category  |
    | Sentence 1  | Homonym       | yes       | 0     | Phones  | Sound     |
    When I go to the Syntactic Structures search page
    Then I should not see "Phones" within ".container" 
    #it's still in the dropdown and is supposed to be there
    And I should not see "Sentence 1"
    And I should not see "Homonym"

  Scenario: Visitor cannot save search
    When I go to the Syntactic Structures search page
    And I press "Show results"
    Then I should not see "Save search results"
