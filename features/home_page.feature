Feature: Linguistic Explorer Home Page
  Background:
    Given I am a visitor
    And the public group "Syntactic Structures"
    When I go to the home page

  Scenario: Visitor can view home page
    Then I should see "TerraLing"

  Scenario: Visitor can visit a public group
    And I follow "public groups"
    And I follow "Syntactic Structures"
    Then I should be on the group Syntactic Structures

  Scenario: Visitor can read Group Info
    And I follow "public groups"
    And I follow "Syntactic Structures"
    And I follow "Group Info"
    Then I should be on the info page for Syntactic Structures

  Scenario: Visitor can search a public group
    When I go to the group Syntactic Structures
    And I follow "Search"
    Then I should see "Search Syntactic Structures"
    And I should be on the Syntactic Structures search page

  Scenario: Visitor haven't any saved searches
    When I go to my group searches page
    Then I should see "You are not authorized"

  # Scenario: Visitor can visit forums
  #   Then I should see "Forums"
