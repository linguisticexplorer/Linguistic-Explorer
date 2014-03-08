Feature: Search with Any in Properties (Both Depth 0 and 1)

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group has a maximum depth of 1
    And the following "Syntactic Structures" lings:
      | name        | parent    |depth |
      | Speaker 1   |           | 0     |
      | Speaker 2   |           | 0     |
      | Speaker 3   |           | 0     |
      | Sentence 1  | Speaker 1 | 1     |
      | Sentence 2  | Speaker 2 | 1     |
      | Sentence 3  | Speaker 3 | 1     |
    And the following "Syntactic Structures" properties:
      | property name     | ling name   | prop val    | category    | depth |
      | Property 1        | Speaker 1   | yes         | Demographic | 0     |
      | Property 2        | Speaker 1   | yes         | Demographic | 0     |
      | Property 1        | Speaker 3   | yes         | Demographic | 0     |
      | Property 3        | Speaker 2   | yes         | Demographic | 0     |
      | Property 4        | Sentence 1  | boh         | Linguistic  | 1     |
      | Property 5        | Sentence 1  | boh         | Linguistic  | 1     |
      | Property 6        | Sentence 3  | boh         | Linguistic  | 1     |
      | Property 7        | Sentence 2  | boh         | Linguistic  | 1     |


  Scenario: Visitor allows all properties
    When I go to the Syntactic Structures search page
    And I press "Show results"
    Then I should see the following search results:
      | Lings         | Properties        | Value     | depth   |
      | Speaker 1     | Property 1        | yes       | parent  |
      | Sentence 1    | Property 4        | boh       | child   |
      | Speaker 1     | Property 1        | yes       | parent  |
      | Sentence 1    | Property 5        | boh       | child   |
      | Speaker 1     | Property 2        | yes       | parent  |
      | Sentence 1    | Property 4        | boh       | child   |
      | Speaker 1     | Property 2        | yes       | parent  |
      | Sentence 1    | Property 5        | boh       | child   |

  Scenario: Visitor searches any property
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Properties"
    And I press "Show results"
    Then I should see "Results"
    Then I should see the following search results:
      | Lings         | Properties        | Value     | depth   |
      | Speaker 1     | Property 1        | yes       | parent  |
      | Sentence 1    | Property 4        | boh       | child   |
      | Speaker 1     | Property 1        | yes       | parent  |
      | Sentence 1    | Property 5        | boh       | child   |
      | Speaker 3     | Property 1        | yes       | parent  |
      | Sentence 3    | Property 6        | boh       | child   |
    And I should not see "Property 2"
    And I should not see "Property 3"

