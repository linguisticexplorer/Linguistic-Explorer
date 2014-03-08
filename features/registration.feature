Feature: Registration

  Scenario: Vistor Registers
    Given I am a visitor
    When I go to the home page
    When I follow "Sign Up"
    And  I should be on the registration page
    When I fill in "Email" with "foo@bar.com"
    And  I fill in "Name" with "bob jonez"
    And  I fill in "Password" with "hunter2"
    And  I fill in "Password confirmation" with "hunter2"
    And  I fill in the CAPTCHA correctly
    And  I press "Sign Up"
    Then I should be on the home page
    And  I should see "You have signed up successfully"
    And  I should see "foo@bar.com"

  Scenario: Attempting to Register with bad data
    Given I am a visitor
    When I go to the home page
    Then I should see "Sign Up"
    When I follow "Sign Up"
    And  I should be on the registration page
    When I clear "Email"
    And  I fill in "Name" with "bob jonez" 
    And  I fill in "Password" with "hunter2" 
    And  I fill in "Password confirmation" with "hunter2" 
    And  I press "Sign Up"
    Then I should not be on the home page
    Then I should see "errors"
    And  I should see "Email" within "#error_explanation"
    When I clear "Name"
    And  I fill in "Email" with "bob jonez"
    And  I fill in "Password" with "hunter2"
    And  I fill in "Password confirmation" with "hunter2"
    And  I press "Sign Up"
    Then I should see "errors"
    And  I should see "Name" within "#error_explanation"
    And  I should see "Email" within "#error_explanation"
    When I fill in "Name" with "mike joanz"
    And  I fill in "Email" with "bob@jonez.com"
    And  I fill in "Password" with "2man"
    And  I fill in "Password confirmation" with "hunter2"
    And  I press "Sign Up"
    Then I should see "errors"
    And  I should see "Password" within "#error_explanation"
    When I fill in "Name" with "mike joanz"
    And  I fill in "Email" with "bob@jonez.com"
    And  I fill in "Password" with ""
    And  I fill in "Password confirmation" with "hunter2"
    And  I press "Sign Up"
    Then I should see "errors"
    And  I should see "Password" within "#error_explanation"
