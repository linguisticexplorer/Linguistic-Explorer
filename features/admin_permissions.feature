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
    When I follow "Sign In"
    Then I should be on the login page
    When I fill in "Email" with "a@min.com"
    And  I fill in "Password" with "hunter2"
    And  I press "Sign In"
    Then I should be on the home page
    And  I should see "a@min.com"
    And  I should see "Signed in successfully"
    And  I should see "Site Admin" within "#userInfo"

  Scenario: Admins should see all groups in the drop down
    Then I should see "Syntactic Structures" within "#group_id"
    And  I should see "Secret Club" within "#group_id"

  Scenario: Admins should be able to view a public group and see its group admin panel
    When I follow "Syntactic Structures" within "#group_id"
    Then I should see "Syntactic Structures" within "#header"

  Scenario: Admins view pages for all group data in a public group
    When I follow "Syntactic Structures" within "#group_id"
    Then I should see "Syntactic Structures" within "#header"
    When I follow "Advanced Search"
    Then I should be on the search page for Syntactic Structures
    #And  I go to the lings page for Syntactic Structures
    #Then I should be on the lings page for Syntactic Structures
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
    When I follow "Secret Club" within "#group_id"

  Scenario: Admins view pages for all group data in a private group
    When I follow "Secret Club" within "#group_id"
    And  I follow "Search"
    Then I should be on the search page for Secret Club
    #And  I go to the lings page for Secret Club
    #Then I should be on the lings page for Secret Club
    And  I follow "Ling0"
    Then I should be on the ling0s page for Secret Club
    And  I follow "Ling1"
    Then I should be on the ling1s page for Secret Club
    And  I follow "Properties"
    Then I should be on the properties page for Secret Club
    And  I follow "Members"
    Then I should be on the memberships page for Secret Club

  Scenario: Admins should be able to manage forum groups
    Then I should see "Forums" within ".navbar-inner"
    Then I follow "Forums"
    And I should see "New Forum Group"

