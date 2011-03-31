Feature: Permissions testing for non-logged-in users

  Background:
    Given I am a visitor
    And the public group "Syntactic Structures"
    And the private group "Secret Club"
    When I go to the home page
    Then I should see "Select a Group"
    And  I should not see "Site Admin Panel"

  Scenario: Visitors should be able to choose a public group to enter
    When I select "Syntactic Structures" from "Select a Group"
    And  I press "Go"
    Then I should be on the group Syntactic Structures

  Scenario: The standard user should be able to view pages for all group data in a public group
    When I select "Syntactic Structures" from "Select a Group"
    And  I press "Go"
    Then I should see the nav links for "Syntactic Structures"
#    Then I should see "Syntactic Structures", "Search", "Ling", "Property", "Value", "Example", "Example Value", "Members"
    And  I should not see "Group Admin Panel"
    When I press "Syntactic Structures"
    Then I should be on the group Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Search"
    Then I should be on the search page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Ling"
    Then I should be on the ling page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Property"
    Then I should be on the property page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Value"
    Then I should be on the value page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Example"
    Then I should be on the example page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Example Value"
    Then I should be on the example value page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Members"
    Then I should be on the memberships page for Syntactic Structures

  Scenario: Visitors should not able to see any private groups listed
    Then "Select a Group" should not contain "Secret Club"
    When I attempt to force a visit to the group Secret Club
    Then I should be on the access denied page

  Scenario: The standard user should not be able to view pages for any group data in a private group
    When I go to the group Secret Club
    Then I should be on the access denied page
    When I go to the search page for Secret Club
    Then I should be on the access denied page
    When I go to the ling page for Secret Club
    Then I should be on the access denied page
    When I go to the property page for Secret Club
    Then I should be on the access denied page
    When I go to the value page for Secret Club
    Then I should be on the access denied page
    When I go to the example page for Secret Club
    Then I should be on the access denied page
    When I go to the example value page for Secret Club
    Then I should be on the access denied page
    When I go to the membership page for Secret Club
    Then I should be on the access denied page
