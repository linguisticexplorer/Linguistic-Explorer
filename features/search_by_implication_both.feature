Feature: Search with Implication Both

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Speaker 3   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    | Sentence 3  | Speaker 3   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 1    | Speaker 2   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 1   | Western   | Demographic | 0     |
    | Property 2    | Speaker 2   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 3   | Eastern   | Demographic | 0     |
    | Property 3    | Speaker 1   | Western   | Demographic | 0     |
    | Property 3    | Speaker 3   | Eastern   | Demographic | 0     |
    | Property 4    | Speaker 2   | Western   | Demographic | 0     |
    | Property 4    | Speaker 3   | Western   | Demographic | 0     |
    | Property 5    | Sentence 1  | Eastern   | Linguistic  | 1     |
    | Property 5    | Sentence 2  | Western   | Linguistic  | 1     |
    | Property 5    | Sentence 3  | Western   | Linguistic  | 1     |
    | Property 6    | Sentence 1  | Eastern   | Linguistic  | 1     |
    | Property 7    | Sentence 1  | Western   | Linguistic  | 1     |
    | Property 7    | Sentence 2  | Eastern   | Linguistic  | 1     |
    | Property 7    | Sentence 3  | Western   | Linguistic  | 1     |
    | Property 8    | Sentence 2  | Western   | Linguistic  | 1     |

  Scenario: Visitor searches Implication Both with all Properties and Lings
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    And I should not see "Speaker 1"
    And I should not see "Sentence 1"
    And I should not see "verb"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | Eastern          | Property 4      | Western          |   2   |
    | Property 4      | Western          | Property 2      | Eastern          |   2   |
    | Property 2      | Western          | Property 1      | Eastern          |   1   |
    | Property 2      | Western          | Property 3      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | Western          | Property 1      | Eastern          |   1   |
    | Property 3      | Western          | Property 2      | Western          |   1   |
    | Property 3      | Eastern          | Property 2      | Eastern          |   1   |
    | Property 3      | Eastern          | Property 4      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | Eastern          | Property 6      | Eastern          |   1   |
    | Property 5      | Eastern          | Property 7      | Western          |   1   |
    | Property 6      | Eastern          | Property 5      | Eastern          |   1   |
    | Property 6      | Eastern          | Property 7      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | Eastern          | Property 5      | Western          |   1   |
    | Property 7      | Eastern          | Property 8      | Western          |   1   |
    | Property 8      | Western          | Property 5      | Western          |   1   |
    | Property 8      | Western          | Property 7      | Eastern          |   1   |

  # Using a Constraint in Linguistic as a trick to filter them
  Scenario: Visitor searches Implication Both with all Demographic Properties
    When I go to the Syntactic Structures search page
    And I select "Property 7" from "Linguistic Properties"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | Eastern          | Property 4      | Western          |   2   |
    | Property 4      | Western          | Property 2      | Eastern          |   2   |
    | Property 2      | Western          | Property 1      | Eastern          |   1   |
    | Property 2      | Western          | Property 3      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | Western          | Property 1      | Eastern          |   1   |
    | Property 3      | Western          | Property 2      | Western          |   1   |
    | Property 3      | Eastern          | Property 2      | Eastern          |   1   |
    | Property 3      | Eastern          | Property 4      | Western          |   1   |

  # Using a Constraint in Demographic as a trick to filter them
  Scenario: Visitor searches Implication Both with all Linguistic Properties
    When I go to the Syntactic Structures search page
    And I select "Property 2" from "Demographic Properties"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | Eastern          | Property 6      | Eastern          |   1   |
    | Property 5      | Eastern          | Property 7      | Western          |   1   |
    | Property 6      | Eastern          | Property 5      | Eastern          |   1   |
    | Property 6      | Eastern          | Property 7      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | Eastern          | Property 5      | Western          |   1   |
    | Property 7      | Eastern          | Property 8      | Western          |   1   |
    | Property 8      | Western          | Property 5      | Western          |   1   |
    | Property 8      | Western          | Property 7      | Eastern          |   1   |


  Scenario: Visitor searches Implication Both for Properties and Languages with Constraints
    When I go to the Syntactic Structures search page
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | Eastern          | Property 4      | Western          |   2   |
    | Property 4      | Western          | Property 2      | Eastern          |   2   |
    | Property 1      | Eastern          | Property 2      | Eastern          |   1   |
    | Property 1      | Eastern          | Property 4      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | Eastern          | Property 2      | Eastern          |   1   |
    | Property 3      | Eastern          | Property 4      | Western          |   1   |
    | Property 7      | Western          | Property 5      | Western          |   1   |
    | Property 7      | Eastern          | Property 5      | Western          |   1   |
    And I follow "Next"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | Eastern          | Property 8      | Western          |   1   |
    | Property 8      | Western          | Property 5      | Western          |   1   |
    | Property 8      | Western          | Property 7      | Eastern          |   1   |


  Scenario: Visitor searches a combination by Implication Both expecting no results
   When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 8" from "Linguistic Properties"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows