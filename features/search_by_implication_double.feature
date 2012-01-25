Feature: Search with Double Both Implication

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

  Scenario: Visitor searches Implication Double Both
    When I go to the Syntactic Structures search page
    And show me the page
    And I choose Implication "Double" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 2      | no               | Property 3      | no               |   1   |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 7      | yes              | Property 8      | no               |   1   |

  Scenario: Visitor searches Implication Double Both within Demographic
    When I go to the Syntactic Structures search page
    And I uncheck "Linglet" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |
    | Property 2      | no               | Property 3      | no               |   1   |

  Scenario: Visitor searches Implication Double Both within Linguistic
    When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |
    | Property 7      | yes              | Property 8      | no               |   1   |

  Scenario: Visitor searches Implication Double Both within Demographic with Languages Constraints
    When I go to the Syntactic Structures search page
    And I uncheck "Linglet" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |

  Scenario: Visitor scearches Implication Double both within Linguistic with Languages Constraints
    When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I select "Speaker 2" from "Lings"
    And I select "Speaker 3" from "Lings"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 7      | yes              | Property 8      | no               |   1   |

  Scenario: Visitor searches Implication Double Both within Demographic with Properties Constraints
    When I go to the Syntactic Structures search page
    And I uncheck "Linglet" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I select "Property 2" from "Demographic Properties"
    And I select "Property 4" from "Demographic Properties"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 2      | yes              | Property 4      | no               |   2   |

  Scenario: Visitor searches Implication Double both within Linguistic with Properties Constraints
    When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I select "Property 5" from "Linguistic Properties"
    And I select "Property 6" from "Linguistic Properties"
    And I press "Show results"
    Then I should see the following Implication search results:
    | Property Name 1 | Property Value 1 | Property Name 2 | Property Value 2 | Count |
    | Property 5      | yes              | Property 6      | yes              |   1   |

  Scenario: Visitor searches and uncheck both depths for Implication Double Both expecting no results
   When I go to the Syntactic Structures search page
    And I uncheck "Ling" within "#show_impl"
    And I uncheck "Linglet" within "#show_impl"
    And I choose Implication "Double" within "#advanced_set"
    And I press "Show results"
    Then I should see no search result rows