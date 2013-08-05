Feature: Using the mass lings-property value setting form

  Background:
    Given the group "Syntactic Structures"
    And the group has a maximum depth of 1
    And the following "Syntactic Structures" lings:
    | name        | depth |
    | English     | 0     |
    | French      | 0     |
    | 2HeadGiant  | 1     |
    And the following "Syntactic Structures" properties:
    | property name     | ling name   | prop val    | category | depth |
    | Adjective Noun    | English     | yes         | Grammar  | 0     |
    | Adjective Degree  | English     | yes         | Grammar  | 0     |
    | Adjective Foo     | French      | sometimes   | Grammar  | 0     |
    | SomethingOther    | 2HeadGiant  | yes         | LevelTwo | 1     |
    | SomethingElse     | 2HeadGiant  | no          | LevelTwo | 1     |
    And there is no value set for the ling "English" with the property "Adjective Foo"

    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"

  @wip
  Scenario: Signed in members can get to the ling mass setting form
    Then I should see "English"
    When I follow "English"
    Then I should see "Edit Values"
    When I follow "Edit Values"
    Then I should be on the mass assignment page for "English"

  Scenario: The page lists category-divided checkbox lists for LingsProperties and available values
    When I am on the mass assignment page for "English"
    Then I should see "Grammar"
    And I should not see "LevelTwo"
    And I should see "Adjective Noun"
    And I should see "Adjective Degree"
    And I should not see "SomethingOther"

  Scenario: Values are listed as checkbox options, prechecked if already set
    When I am on the mass assignment page for "English"
    And the "sometimes" checkbox within "#AdjectiveFoo" should not be checked
    Then the "yes" checkbox within "#AdjectiveNoun" should be checked
    And the "yes" checkbox within "#AdjectiveDegree" should be checked
