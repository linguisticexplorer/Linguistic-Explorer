Feature: Permissions testing for non-logged-in users

  Background:
    Given I am a visitor
    And the public group "Syntactic Structures"
    And the private group "Secret Club"
    When I go to the home page
    And I follow "Syntactic Structures" within "#group_id"

  Scenario: Visitors should be able to choose a public group to enter
    Then I should be on the group Syntactic Structures
    Then I should see "Syntactic Structures" within "#group_id"

  Scenario: The standard user should be able to view pages for all group data in a public group
    Then I should see "Syntactic Structures" within "#group_id"
    And  I should not see "Group Admin Panel"
    When I follow "Syntactic Structures"
    Then I should be on the group Syntactic Structures
    And  I follow "Advanced Search"
    Then I should be on the search page for Syntactic Structures
    When I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    Then I should be on the ling0s page for Syntactic Structures
    And  I follow the "Ling" with depth "1" model link for the group "Syntactic Structures"
    Then I should be on the ling1s page for Syntactic Structures
    And  I follow "Properties"
    Then I should be on the properties page for Syntactic Structures
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
    When I go to the examples page for Secret Club
    Then I should be on the access denied page
    When I go to the memberships page for Secret Club
    Then I should be on the access denied page

  # Scenario: Visitors should not able to create a new forum
  #   When I should see "TerraLing"
  #   Then I should see "Forums" within ".nav"
  #   Then I follow "Forums"
  #   And I should not see "New Forum Group"
