Feature: Search with Implication Antecedent

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

  Scenario: Visitor searches Implication Antecedent with Languages Constraints
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Lings"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | no               | Property 1      | yes              |   1   |
    | Property 2      | no               | Property 3      | no               |   1   |
    | Property 3      | no               | Property 1      | yes              |   1   |
    | Property 3      | no               | Property 2      | no               |   1   |
    # And I follow "Next"
    # Then I should see the following Implication search results:
    # | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 5      | yes              | Property 7      | no               |   1   |
    | Property 6      | yes              | Property 5      | yes              |   1   |
    | Property 6      | yes              | Property 7      | no               |   1   |

  Scenario: Visitor searches Implication Antecedent with Languages Constraints on Demographics, showing Linguistics
    When I go to the Syntactic Structures search page
    And I uncheck "Implication on Ling"
    And I select "Speaker 1" from "Lings"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 5      | yes              | Property 7      | no               |   1   |
    | Property 6      | yes              | Property 5      | yes              |   1   |
    | Property 6      | yes              | Property 7      | no               |   1   |

  Scenario: Visitor searches Implication Antecedent with Properties Constraints on Demographic
    When I go to the Syntactic Structures search page
    And I uncheck "Implication on Linglet"
    And I select "Property 3" from "Demographic Properties"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 3      | no               | Property 1      | yes              |   1   |
    | Property 3      | no               | Property 2      | no               |   1   |
    | Property 3      | yes              | Property 2      | yes              |   1   |
    | Property 3      | yes              | Property 4      | no               |   1   |

  Scenario: Visitor searches Implication Antecedent with all Properties and Lings: should be the same as Implication Both
    When I go to the Syntactic Structures search page
    And I choose "Antecedent" within "#advanced_set"
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

  Scenario: Visitor searches Implication Antecedent with all Properties and Lings: should be the same as Implication Both, showing Linguistics
    When I go to the Syntactic Structures search page
    And I uncheck "Implication on Ling"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    And I should not see "Speaker 1"
    And I should not see "Sentence 1"
    And I should not see "verb"
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

  Scenario: Visitor searches a combination by Implication Antecedent expecting no results
   When I go to the Syntactic Structures search page
    And I select "Property 3" from "Demographic Properties"
    And I select "Property 8" from "Linguistic Properties"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows

  Scenario: Visitor searches and uncheck both depths for Implication Antecedent expecting no results
   When I go to the Syntactic Structures search page
    And I uncheck "Implication on Ling"
    And I uncheck "Implication on Linglet"
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows