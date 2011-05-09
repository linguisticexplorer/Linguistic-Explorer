Feature: Search with Any

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group has a maximum depth of 0
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

  Scenario: Visitor allows all properties
    When I go to the Syntactic Structures search page
    And I press "Search"
    Then I should see the following search results:
    | Lings         | Properties        | Value     |
    | English       | Adjective Noun    | yes       |
    | English       | Adjective Degree  | yes       |
    | Spanish       | Adjective Noun    | yes       |
    | German        | Degree Adjective  | yes       |

  Scenario: Visitor searches any property
    When I go to the Syntactic Structures search page
    And I select "Adjective Noun" from "Properties"
    And I press "Search"
    Then I should see "Results"
    Then I should see the following search results:
    | Lings         | Properties        | Value     |
    | English       | Adjective Noun    | yes       |
    | Spanish       | Adjective Noun    | yes       |
    And I should not see "Adjective Degree"
    And I should not see "Degree Adjective"

