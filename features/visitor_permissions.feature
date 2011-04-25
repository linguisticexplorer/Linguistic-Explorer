Feature: Permissions testing for non-logged-in users

  Background:
    Given I am a visitor
    And the public group "Syntactic Structures"
    And the private group "Secret Club"
    When I go to the home page
    Then I should see "Select a Group"

  Scenario: Visitors should be able to choose a public group to enter
    When I select "Syntactic Structures" from "group_id"
    And  I press "Go"
    Then I should be on the group Syntactic Structures
    Then I should see "Syntactic Structures" within "#group_nav_bar"

  Scenario: The standard user should be able to view pages for all group data in a public group
    When I select "Syntactic Structures" from "group_id"
    And  I press "Go"
    Then I should see "Syntactic Structures" within "#group_nav_bar"
    And  I should not see "Group Admin Panel"
    When I follow "Syntactic Structures"
    Then I should be on the group Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Search"
    Then I should be on the search page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Ling"
    Then I should be on the ling page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Property"
    Then I should be on the property page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Value"
    Then I should be on the value page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Example"
    Then I should be on the example page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Example Value"
    Then I should be on the example value page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Members"
    Then I should be on the memberships page for Syntactic Structures

  Scenario: Visitors should not able to see private groups
    When I go to the group Secret Club
    Then I should be on the access denied page

  Scenario: Visitors should not be able to view pages for any group data in a private group
    When I go to the group Secret Club
    Then I should be on the access denied page
    When I go to the search page for Secret Club
    Then I should be on the access denied page
    When I go to the lings page for Secret Club
    Then I should be on the access denied page
    When I go to the ling0s page for Secret Club
    Then I should be on the access denied page
    When I go to the ling1s page for Secret Club
    Then I should be on the access denied page
    When I go to the properties page for Secret Club
    Then I should be on the access denied page
    When I go to the values page for Secret Club
    Then I should be on the access denied page
    When I go to the examples page for Secret Club
    Then I should be on the access denied page
    When I go to the example values page for Secret Club
    Then I should be on the access denied page
    When I go to the memberships page for Secret Club
    Then I should be on the access denied page
