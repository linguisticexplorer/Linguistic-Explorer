Feature: Creating a Ling

  Background:
    Given the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    Given I am a visitor
    And I go to the group Syntactic Structures

  Scenario: Visitor can create a ling of depth 0
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    When I follow "New Speaker"
    Then I should see "New Speaker"
    When I fill in "Englishman" for "Name"
    And I press "Create Speaker"
    Then I should see "Speaker was successfully created"
    And I should see "Englishman"

  Scenario: Visitor can create a ling of depth 1
    And I follow the "Ling" with depth "1" model link for the group "Syntactic Structures"
    When I follow "New Sentence"
    Then I should see "New Sentence"
    When I fill in "Sentence 99" for "Name"
    And I press "Create Sentence"
    Then I should see "Sentence was successfully created"
    And I should see "Sentence 99"
