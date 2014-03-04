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
    | Property 1    | Speaker 1   | yes       | Demographic | 0     |
    | Property 1    | Speaker 2   | yes       | Demographic | 0     |
    | Property 2    | Speaker 1   | no        | Demographic | 0     |
    | Property 2    | Speaker 2   | yes       | Demographic | 0     |
    | Property 2    | Speaker 3   | yes       | Demographic | 0     |
    | Property 3    | Speaker 1   | no        | Demographic | 0     |
    | Property 3    | Speaker 3   | yes       | Demographic | 0     |
    | Property 4    | Speaker 2   | no        | Demographic | 0     |
    | Property 4    | Speaker 3   | no        | Demographic | 0     |
    | Property 5    | Sentence 1  | yes       | Linguistic  | 1     |
    | Property 5    | Sentence 2  | no        | Linguistic  | 1     |
    | Property 5    | Sentence 3  | no        | Linguistic  | 1     |
    | Property 6    | Sentence 1  | yes       | Linguistic  | 1     |
    | Property 7    | Sentence 1  | no        | Linguistic  | 1     |
    | Property 7    | Sentence 2  | yes       | Linguistic  | 1     |
    | Property 7    | Sentence 3  | no        | Linguistic  | 1     |
    | Property 8    | Sentence 2  | no        | Linguistic  | 1     |
    And I want at most "25" results per page

  Scenario: Visitor searches Implication Both with all Properties and Lings
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    And I should not see "Speaker 1"
    And I should not see "Sentence 1"
    And I should not see "verb"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 4      | no               | Property 2      | yes              |   2   |
    | Property 2      | no               | Property 1      | yes              |   1   |
    | Property 2      | no               | Property 3      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | no               | Property 1      | yes              |   1   |
    | Property 3      | no               | Property 2      | no               |   1   |
    | Property 3      | yes              | Property 2      | yes              |   1   |
    | Property 3      | yes              | Property 4      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 5      | yes              | Property 7      | no               |   1   |
    | Property 6      | yes              | Property 5      | yes              |   1   |
    | Property 6      | yes              | Property 7      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | yes              | Property 5      | no               |   1   |
    | Property 7      | yes              | Property 8      | no               |   1   |
    | Property 8      | no               | Property 5      | no               |   1   |
    | Property 8      | no               | Property 7      | yes              |   1   |

  Scenario: Visitor searches Implication Both with all Demographic Properties
    When I go to the Syntactic Structures search page
    And I check "Ling" within "#show_impl"
    And I uncheck "Linglet" within "#show_impl"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 4      | no               | Property 2      | yes              |   2   |
    | Property 2      | no               | Property 1      | yes              |   1   |
    | Property 2      | no               | Property 3      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | no               | Property 1      | yes              |   1   |
    | Property 3      | no               | Property 2      | no               |   1   |
    | Property 3      | yes              | Property 2      | yes              |   1   |
    | Property 3      | yes              | Property 4      | no               |   1   |

  Scenario: Visitor searches Implication Both with all Linguistic Properties
    When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I check "Linglet" within "#show_impl"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 5      | yes              | Property 7      | no               |   1   |
    | Property 6      | yes              | Property 5      | yes              |   1   |
    | Property 6      | yes              | Property 7      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | yes              | Property 5      | no               |   1   |
    | Property 7      | yes              | Property 8      | no               |   1   |
    | Property 8      | no               | Property 5      | no               |   1   |
    | Property 8      | no               | Property 7      | yes              |   1   |


  Scenario: Visitor searches Implication Both for Properties and Languages with Constraints
    When I go to the Syntactic Structures search page
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 4      | no               | Property 2      | yes              |   2   |
    | Property 1      | yes              | Property 2      | yes              |   1   |
    | Property 1      | yes              | Property 4      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | yes              | Property 2      | yes              |   1   |
    | Property 3      | yes              | Property 4      | no               |   1   |
    | Property 7      | no               | Property 5      | no               |   1   |
    | Property 7      | yes              | Property 5      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | yes              | Property 8      | no               |   1   |
    | Property 8      | no               | Property 5      | no               |   1   |
    | Property 8      | no               | Property 7      | yes              |   1   |

  Scenario: Visitor searches Implication Both for Properties and Languages with Constraints, Demographic results
    When I go to the Syntactic Structures search page
    And I uncheck "Linglet" within "#show_impl"
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 4      | no               | Property 2      | yes              |   2   |
    | Property 1      | yes              | Property 2      | yes              |   1   |
    | Property 1      | yes              | Property 4      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | yes              | Property 2      | yes              |   1   |
    | Property 3      | yes              | Property 4      | no               |   1   |
    And I should not see "Property 7"

  Scenario: Visitor searches Implication Both for Properties and Languages with Constraints, Linguistic results
    When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    And I should not see "Property 2"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | no               | Property 5      | no               |   1   |
    | Property 7      | yes              | Property 5      | no               |   1   |
    | Property 7      | yes              | Property 8      | no               |   1   |
    | Property 8      | no               | Property 5      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 8      | no               | Property 7      | yes              |   1   |


  Scenario: Visitor searches a combination by Implication Both expecting no results
   When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 8" from "Linguistic Properties"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows

  Scenario: Visitor searches and uncheck both depths for Implication Both expecting no results
   When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I uncheck "Linglet" within "#show_impl"
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows