Feature: Geo Mapping

  Background:
    Given I am a visitor
    And the group "Syntactic Structures"
    And the group has a maximum depth of 0
    And the following "Syntactic Structures" lings:
      | name        | parent      | depth |
      | Speaker 1   |             | 0     |
      | Speaker 2   |             | 0     |
      | Speaker 3   |             | 0     |
    And the following "Syntactic Structures" properties:
      | property name | ling name   | prop val  | category    | depth |
      | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
      | Property 1    | Speaker 3   | Eastern   | Demographic | 0     |
      | Property 2    | Speaker 1   | Western   | Demographic | 0     |
      | Property 2    | Speaker 2   | Western   | Demographic | 0     |
      | latlong       | Speaker 1   | 1,1       | Demographic | 0     |
      | latlong       | Speaker 2   | 2,2       | Demographic | 0     |

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
    And I select "Speaker 2" from "Ling"
    And I press "Show results"
    Then I should see no search result rows
    Then I should not see "Map it!"

  Scenario: Visitor search with results but lings haven't any geographical data to show
    When I go to the Syntactic Structures search page
    And I select "Speaker 3" from "Ling"
    And I press "Show results"
    And I should see "Map it!"
    Then I follow "Map it!"
    And I should not see a map
    And I should see "Sorry, no geographical data to show on the map!"

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
    And I select "Speaker 1" from "Ling"
    And I select "Speaker 2" from "Ling"
    And I choose "Compare" within "#ling"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search to compare lings and go to the map
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Ling"
    And I select "Speaker 2" from "Ling"
    And I choose "Compare" within "#ling"
    And I press "Show results"
    Then I should see "Map it!"
    Then I follow "Map it!"
    Then I should see a map

  Scenario: Visitor search to implication and the map link is in the results page
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search to implication and the map link is in the results page
    When I go to the Syntactic Structures search page
    And I choose "Antecedent" within "#advanced_set"
    And I press "Show results"
    Then I should see "Map it!"

  Scenario: Visitor search to implication and go to the map
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I press "Show results"
    Then I should see "Map it!"
    Then I follow "Map it!"
    Then I should see a map
  
  @devOnly
  Scenario: Visitor search for similarity tree and not see the Map it! link
    When I go to the Syntactic Structures search page
    And I choose "Tree" within "#advanced_set"
    And I press "Show results"
    Then I should not see "Map it!"