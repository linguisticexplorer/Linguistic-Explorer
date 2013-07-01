Feature: Signing in and out

  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
      | bob     | bob@dole.com  | hunter2   | user          |
    When I go to the home page

  Scenario: A standard user can find a sign in on the homepage
    Then I should see "Sign In"
    Then I should not see "Sign Out"

  Scenario: The standard user signs in successfully from the home page
    When I follow "Sign In"
    Then I should be on the login page
    When I fill in "Email" with "bob@dole.com"
    And  I fill in "Password" with "hunter2"
    And  I press "Sign In"
    Then I should be on the home page
    And  I should see "bob@dole.com"
    And  I should see "Signed in successfully"

  Scenario: The standard user is signed in and then signs out
    Given I am signed in as "bob@dole.com"
    Then  I should see "Sign Out"
    When  I follow "Sign Out"
    Then  I should be on the home page
    And   I should see "Sign In"

  Scenario: The standard user mismatches email/pass
    When I follow "Sign In"
    Then I should be on the login page
    When I fill in "Email" with "bob@dole.com"
    And  I fill in "Password" with "idontknow!"
    And  I press "Sign In"
    Then I should be on the login page
    And  I should not see "bob@dole.com"
    And  I should see "Invalid email or password"

  Scenario: The administrator is signed in and then signs out
    Given I am signed in as "a@min.com"
    Then  I should see "Sign Out"
    When  I follow "Sign Out"
    Then  I should be on the home page
    And   I should see "Sign In"
