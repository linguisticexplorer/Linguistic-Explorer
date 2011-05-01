Feature: Linguistic Explorer Home Page

  Scenario: Visitor can view home page
    Given I am a visitor
    When I go to the home page
    Then I should see "TerraLing"

  Scenario: Visitor can start new search
    Given I am a visitor
    And the public group "Syntactic Structures"
    When I go to the home page
    And I follow "Groups"
    And I follow "Syntactic Structures"
    And I follow "Search"
    Then I should see "Search Syntactic Structures"

  Scenario: When in previews
    Given I am a visitor
    And the settings "in preview" is true
    And the public group "Syntactic Structures"
    When I go to the home page
    Then I should not see "Groups"
    And I should not see "Search"
    Then I should see "Coming soon"

  Scenario: No saved searches
    Given I am a visitor
    And the public group "Syntactic Structures"
    When I go to my group searches page
    Then I should see "You are not authorized"
