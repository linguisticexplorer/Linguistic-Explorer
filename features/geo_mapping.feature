Feature: Geo Mapping

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
      | ling0_name  | ling1_name |
      | Speakers    | Sentences  |
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
      | Property 1    | Speaker 3   | Eastern   | Demographic | 0     |
      | Property 2    | Speaker 1   | Western   | Demographic | 0     |
      | Property 2    | Speaker 2   | Western   | Demographic | 0     |
      | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
      | Property 3    | Sentence 3  | noun      | Linguistic  | 1     |
      | Property 4    | Sentence 1  | noun      | Linguistic  | 1     |
      | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |

  Scenario: Visitor search and the map link is in the results page
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search and go to the map
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I press "Show results"
    Then I should see "Map it!"
    Then I follow "Map it!"
    Then I should see a map

  Scenario: Visitor search with no results and no Map it! link in the results page
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Speaker 2" from "Speakers"
    And I press "Show results"
    Then I should see no search result rows
    Then I should not see "Map it!"

  Scenario: Visitor search cross properties and the map link is in the results page
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search cross properties and go to the map
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I press "Show results"
    Then I should see "Map it!"
    Then I follow "Map it!"
    Then I should see a map

  Scenario: Visitor search to compare lings and the map link is in the results page
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Speaker 2" from "Speakers"
    And I choose "Compare" within "#speakers"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search to compare lings and go to the map
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Speaker 2" from "Speakers"
    And I choose "Compare" within "#speakers"
    And I press "Show results"
    Then I should see "Map it!"
    Then I follow "Map it!"
    Then I should see a map

  Scenario: Visitor search to implication and not see the Map it! link
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should not see "Map it!"

  Scenario: Visitor search for similarity tree and not see the Map it! link
    When I go to the Syntactic Structures search page
    And I choose "Tree" within "#advanced_set"
    And I press "Show results"
    Then I should not see "Map it!"