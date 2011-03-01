Feature: Registration

  Scenario: Vistor Registers
    Given I am a visitor
    When I go to the home page
    Then I should see "Sign up"
    When I follow "Sign up"
    And I should be on the registration page
    When I fill in "Email" with "foo@bar.com"
    And I fill in "Name" with "bob jonez"
    And I fill in "Password" with "hunter2"
    And I fill in "Password confirmation" with "hunter2"
    And I press "Sign up"
    Then I should be on the home page
    And I should see "Signed in as foo@bar.com"
    And I should see "You have signed up successfully"
