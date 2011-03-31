Feature: Permissions testing for site admins

  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
    And the public group "Syntactic Structures"
    And the private group "Secret Club"
    When I go to the home page
    Then I should see "Log in"
    When I follow "sign in"
    Then I should be on the login page
    When I fill in "Email" with "a@min.com"
    And  I fill in "Password" with "hunter2"
    And  I press "Sign in"
    Then I should be on the home page
    And  I should see "Signed in as a@min.com"
    And  I should see "Signed in successfully"
    And  I should see "Site Admin Panel"

  Scenario: Admins should see all groups in the dropdown
    Then I should see "Syntactic Structures" within "Select a Group"
    And  I should see "Secret Club" within "Select a Group"

  Scenario: Admins should be able to view a public group and see its group admin panel
    When I select "Syntactic Structures" from "Select a Group"
    And  I press "Go"
    Then I should see the nav links for "Syntactic Structures"
    And  I should see "Group Admin Panel"

  Scenario: Admins view pages for all group data in a public group
    When I select "Syntactic Structures" from "Select a Group"
    And  I press "Go"
    Then I should see the nav links for "Syntactic Structures"
    When I press "Search"
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

  Scenario: Admins should be able to view a private group and see its group admin panel
    When I select "Secret Club" from "Select a Group"
    And  I press "Go"
    Then I should see the nav links for "Secret Club"
    And  I should see "Group Admin Panel"

  Scenario: Admins view pages for all group data in a private group
    When I select "Secret Club" from "Select a Group"
    And  I press "Go"
    Then I should see the nav links for "Secret Club"
    When I press "Search"
    Then I should be on the search page for Secret Club
    When I return to "Secret Club"
    And  I press "Ling"
    Then I should be on the ling page for Secret Club
    When I return to "Secret Club"
    And  I press "Property"
    Then I should be on the property page for Secret Club
    When I return to "Secret Club"
    And  I press "Value"
    Then I should be on the value page for Secret Club
    When I return to "Secret Club"
    And  I press "Example"
    Then I should be on the example page for Secret Club
    When I return to "Secret Club"
    And  I press "Example Value"
    Then I should be on the example value page for Secret Club
    When I return to "Secret Club"
    And  I press "Members"
    Then I should be on the memberships page for Secret Club
