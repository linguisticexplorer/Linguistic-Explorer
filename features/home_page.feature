Feature: Linguistic Explorer Home Page

  Scenario: Visitor can view home page
    Given I am a visitor
    When I go to the home page
    Then I should see "Linguistic Explorer"

  Scenario: User start new search
    Given I am a visitor
    When I go to the home page
    And I follow "Search"
    Then I should see "Start a new search"
