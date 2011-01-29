Feature: Search with Any

  Background:
    Given I am a visitor

    # Ling[] Prop[] Val[]
    # selector for ling
    # selector for prop
    # selector for val
    # choosing any
    # choosing all

  Scenario: Visitor searches any language
    And the following lings:
    | name        |
    | English     |
    | Spanish     |
    | German      |
    When I go to the new search page
    And I check "Include language"
    And I select "English" from "Languages"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should not see "Spanish"

  Scenario: Visitor searches a language and a property
    And the following lings and properties:
    | name        | property_name     | property_value |
    | English     | Adjective Noun    | yes  |
    | English     | Adjective Degree  | yes  |
    | Spanish     | Adjective Noun    | yes  |
    | German      | Adjective Degree  | yes  |
    When I go to the new search page
    And I check "Include language"
    And I check "Include property"
    And I select "English" from "Languages"
    And I select "Adjective Noun" from "Properties"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should see "Adjective Noun" within ".english_property"
    And I should not see "Spanish"
    And I should not see "German"
    And I should not see "Adjective Degree"

  Scenario: Visitor searches multiple languages for a property
    And the following lings and properties:
    | name        | property_name     | property_value |
    | English     | Adjective Noun    | yes  |
    | English     | Adjective Degree  | yes  |
    | Spanish     | Adjective Noun    | yes  |
    | German      | Adjective Degree  | yes  |
    When I go to the new search page
    And I check "Include language"
    And I check "Include property"
    And I select "English" from "Languages"
    And I select "Spanish" from "Languages"
    And I select "German" from "Languages"
    And I select "Adjective Noun" from "Properties"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should see "Spanish"
    And I should see "Adjective Noun" within ".english_property"
    And I should see "Adjective Noun" within ".spanish_property"
    And I should not see "German"
    And I should not see "Adjective Degree"

