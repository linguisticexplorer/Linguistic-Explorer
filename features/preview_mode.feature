Feature: Linguistic Explorer Home Page
  Background:
    Given I am a visitor
    And the setting "Preview" is true
    And the public group "Syntactic Structures"

  Scenario: Home page should be coming soon
    When I go to the home page
    Then I should not see "Groups"
    And I should not see "Search"
    Then I should see "Coming soon"
    # There's no hook for after suite tests in Cucumber
    # so remember to restore it back!
    And the setting "Preview" is false
