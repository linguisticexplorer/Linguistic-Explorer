Feature: Pagination

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
    And I want at most "4" results per page
    And I go to the group Syntactic Structures

  Scenario: Visitor goes to Ling page and navigate with pagination letter button
    When I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    And I should see "Afrikaans"
    And I should see "A" within "#pagination_top"
    And I should see "All" within "#pagination_top"
    And I follow "All" within "#pagination_top"
    And I should see "Italian"
    And I follow "S" within "#pagination_top"
    And I should see "Spanish"

  Scenario: Visitor goes to Properties page and navigate with pagination
    When I follow the "Properties" for the group "Syntactic Structures"
    And I should see "Adjective Noun"
    And I should see "Next" within "#pagination_top"
    And I follow "Next" within "#pagination_top"
    And I should see "Noun Demonstrative"

  Scenario: Visitor goes to Afrikaans ling page and navigate with pagination
    When I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    And I should see "Afrikaans"
    # And I should see "A"
    And I follow "Afrikaans"
    And I should see "Adjective Noun"
    And I should see "Next" within "#pagination_top"
    And I follow "Next" within "#pagination_top"
    And I should see "Noun Demonstrative"

  Scenario: Visitor goes to Afrikaans ling page and navigate properties with pagination
    When I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    And I should see "Afrikaans"
    And I should see "A" within "#pagination_top"
    And I follow "Afrikaans"
    And I should see "Adjective Noun"
    And I should see "Next" within "#pagination_top"
    And I follow "Next" within "#pagination_top"
    And I should see "Noun Demonstrative"

  Scenario: Visitor goes to Property page and navigate lings with pagination
    When I follow the "Properties" for the group "Syntactic Structures"
    And I should see "Adjective Noun"
    And I should see "Degree Adjective"
    And I follow "Degree Adjective"
    Then I should see "Afrikaans"
    Then I should see "S" within "#pagination_top"
    And I follow "S" within "#pagination_top"
    Then I should see "Spanish"

  Scenario: Visitor goes on search page and get results with pagination, on depth 0
    When I go to the Syntactic Structures search page
    And I uncheck "Linglets" within "#show_child"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_child"
    And I select "Afrikaans" from "Lings" within "#lings"
    And I press "Show results"
    Then I should see "Next" within "#pagination_top"
    And I should see "2" within "#pagination_top"
    And I follow "2" within "#pagination_top"
    Then I should see "Noun Demonstrative"

  Scenario: Visitor goes on search page and get results with pagination, on depth 1
    When I go to the Syntactic Structures search page
    And I select "Afrikaans" from "Lings" within "#lings"
    And I press "Show results"
    Then I should see "Next" within "#pagination_top"
    And I should see "2" within "#pagination_top"
    And I follow "2" within "#pagination_top"
    Then I should see "Noun Demonstrative"
