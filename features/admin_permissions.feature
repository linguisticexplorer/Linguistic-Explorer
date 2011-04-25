Feature: Permissions testing for site admins

  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
    And the public group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
      | ling0 | ling1 |
      | Ling0 | Ling1 |
    And the private group "Secret Club"
    And the group "Secret Club" with the following ling names:
      | ling0 | ling1 |
      | Ling0 | Ling1 |
    When I go to the home page
    When I follow "sign in"
    Then I should be on the login page
    When I fill in "Email" with "a@min.com"
    And  I fill in "Password" with "hunter2"
    And  I press "Sign in"
    Then I should be on the home page
    And  I should see "Signed in as a@min.com"
    And  I should see "Signed in successfully"
    And  I should see "site admin" within "#site_admin_bar"

  Scenario: Admins should see all groups in the drop down
    Then I should see "Syntactic Structures" within "#group_id"
    And  I should see "Secret Club" within "#group_id"

  Scenario: Admins should be able to view a public group and see its group admin panel
    When I select "Syntactic Structures" from "group_id"
    And  I press "Go"
    Then I should see "Syntactic Structures" within "#group_nav_bar"
    Then I should see "group admin" within "#group_admin_bar"

  Scenario: Admins view pages for all group data in a public group
    When I select "Syntactic Structures" from "group_id"
    And  I press "Go"
    Then I should see "Syntactic Structures"
    When I press "Search"
    Then I should be on the search page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I go to the lings page for Syntactic Structures
    Then I should be on the lings page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Ling0"
    Then I should be on the ling0 page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I press "Ling1"
    Then I should be on the ling1 page for Syntactic Structures
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
    When I select "Secret Club" from "#group_id"
    And  I press "Go"
    Then I should see "Group admin" within "#group_admin_bar"

  Scenario: Admins view pages for all group data in a private group
    When I select "Secret Club" from "#group_id"
    And  I press "Go"
    Then I should see "Syntactic Structures" within "#group_admin_bar"
    When I press "Search"
    Then I should be on the search page for Secret Club
    When I return to "Secret Club"
    And  I go to the lings page for Secret Club
    Then I should be on the lings page for Secret Club
    When I return to "Secret Club"
    And  I press "Ling0"
    Then I should be on the ling0s page for Secret Club
    When I return to "Secret Club"
    And  I press "Ling1"
    Then I should be on the ling1s page for Secret Club
    When I return to "Secret Club"
    And  I press "Property"
    Then I should be on the properties page for Secret Club
    When I return to "Secret Club"
    And  I press "Value"
    Then I should be on the values page for Secret Club
    When I return to "Secret Club"
    And  I press "Example"
    Then I should be on the examples page for Secret Club
    When I return to "Secret Club"
    And  I press "Example Value"
    Then I should be on the example values page for Secret Club
    When I return to "Secret Club"
    And  I press "Members"
    Then I should be on the memberships page for Secret Club
