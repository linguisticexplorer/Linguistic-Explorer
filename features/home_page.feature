Feature: Linguistic Explorer Home Page

  Scenario: Visitor can view home page
    Given I am a visitor
    When I go to the home page
    Then I should see "Linguistic Explorer"

  Scenario: User start new search
    Given I am a visitor
    And the group "Syntactic Structures"
    When I go to the home page
    And I follow "Groups"
    And I follow "Search"
    Then I should see "Search Syntactic Structures"
