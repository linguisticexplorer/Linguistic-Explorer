Feature: Search Examples

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speakers    | Sentences   |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |
    And the following "Syntactic Structures" examples:
    | example     | ling name   | prop val  |
    | Example 1   | Speaker 1   | Eastern   |
    | Example 2   | Speaker 2   | Western   |
    | Example 3   | Sentence 1  | verb      |
    | Example 4   | Sentence 2  | noun      |

  Scenario: Visitor chooses parent ling examples
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I check "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Example     | depth   |
    | Speaker 1     | Example 1   | parent  |
    | Sentence 1    |             | child   |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"
    And I should not see "Example 2"
    And I should not see "Example 3"
    And I should not see "Example 4"

  Scenario: Visitor chooses child ling examples
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I uncheck "Examples" within "#show_parent"
    And I check "Examples" within "#show_child"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Example     | depth   |
    | Speaker 1     |             | parent  |
    | Sentence 1    | Example 3   | child   |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"
    And I should not see "Example 2"
    And I should not see "Example 1"
    And I should not see "Example 4"

  Scenario: Keyword search on example
    When I go to the Syntactic Structures search page
    And I check "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I fill in "Example Keywords" with "Example 1"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Example     | depth   |
    | Speaker 1     | Example 1   | parent  |
    | Sentence 1    |             | child   |
    And I should not see "Example 2"
    And I should not see "Example 3"
    And I should not see "Example 4"

  Scenario: Partial keyword search on example
    When I go to the Syntactic Structures search page
    And I check "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I fill in "Example Keywords" with "1"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Example     | depth   |
    | Speaker 1     | Example 1   | parent  |
    | Sentence 1    |             | child   |
    And I should not see "Example 2"
    And I should not see "Example 3"
    And I should not see "Example 4"

  Scenario: Keyword search on example stored values
    Given the group example fields "origin, era"
    And the following example stored values
    | example     | key         | value     |
    | Example 1   | origin      | middle    |
    | Example 2   | era         | golden    |
    | Example 3   | era         | olden     |
    | Example 4   | era         | golden    |
    When I go to the Syntactic Structures search page
    And I check "Examples" within "#show_parent"
    And I check "Examples" within "#show_child"
    And I select "Era Contains" from "Speaker Example Attribute"
    And I fill in "Example Keywords" with "gold"
    And I press "Show results"
    Then I should see the following search results:
    | Lings         | Example     | depth   |
    | Speaker 2     | Example 2   | parent  |
    | Sentence 2    | Example 4   | child   |
    And I should not see "Example 1"
    And I should not see "Example 3"
