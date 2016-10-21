Feature: Permissions testing for site admins

  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
    And the public group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
      | ling0_name | ling1_name |
      | Ling0      | Ling1      |
    And the group "Syntactic Structures" has a maximum depth of 1
    And the private group "Secret Club"
    And the group "Secret Club" with the following ling names:
      | ling0_name | ling1_name |
      | Ling0      | Ling1      |
    And the group "Secret Club" has a maximum depth of 1
    When I go to the home page
    When I follow "Sign in"
    Then I should be on the login page
    When I fill in "Email" with "a@min.com"
    And  I fill in "Password" with "hunter2"
    And  I press "Sign in"
    Then I should be on the home page
    And  I should see "admin" within the top navbar
    And  I should see "Site Admin" within the top navbar
    And  I should see "Signed in successfully"

  Scenario: Admins should see all groups in the drop down
    Then I should see "Syntactic Structures" within the top navbar
    And  I should see "Secret Club" within the top navbar

  Scenario: Admins should be able to view a public group and see its group admin panel
    When I follow "Syntactic Structures" within the top navbar
    Then I should see "Syntactic Structures" within "#header"

  @wip
  Scenario: Admins view pages for all group data in a public group
    When I follow "Syntactic Structures" within the top navbar
    Then I should see "Syntactic Structures" within "#header"
    When I follow "Advanced Search"
    Then I should be on the search page for Syntactic Structures
    And  I follow "Ling0s"
    Then I should be on the ling0s page for Syntactic Structures
    And  I follow "Ling1s"
    Then I should be on the ling1s page for Syntactic Structures
    And  I follow "Properties"
    Then I should be on the properties page for Syntactic Structures
    When I return to "Syntactic Structures"
    And  I follow "Members"
    Then I should be on the memberships page for Syntactic Structures

  Scenario: Admins should be able to view a private group and see its group admin bar
    When I follow "Secret Club" within the top navbar

  @wip
  Scenario: Admins view pages for all group data in a private group
    When I follow "Secret Club" within the top navbar
    And  I follow "Search"
    Then I should be on the search page for Secret Club
    And  I follow "Ling0"
    Then I should be on the ling0s page for Secret Club
    And  I follow "Ling1"
    Then I should be on the ling1s page for Secret Club
    And  I follow "Properties"
    Then I should be on the properties page for Secret Club
    And  I follow "Members"
    Then I should be on the memberships page for Secret Club

