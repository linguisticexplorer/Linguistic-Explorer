Feature: Admin can add a new language
  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
    And the group "Group 1" with the following ling names:
      | ling0_name  | ling1_name |
      | Languages   | Speakers   |
    And the following "Group 1" lings:
      | name        | depth |
      | English     | 0     |
    And the following "Group 1" properties:
      | property name     | ling name   | prop val    | depth |
      | Adjective Noun    | English     | yes         | 0     |

  Scenario: I can do it
    Given I am signed in as "a@min.com"
    When I click on Group named "Group 1"
    Then I click to create a new language
    And I set the language name to "language name"
    And I enter a description for the language to "language description"
    And I save the language
    And I set a property value to "Yes"
    And I create an example for the given value with the name "Name", gloss "Gloss", and number "Number"
    And I set a new propery value to "New Property Value"
    When I go back to the language page
    Then I should see that the language "language name" is set by "admin"
    And the language description is set to "language description"
    And that it has an example with gloss "Gloss" and number "Number"
    And the language has a property value set to "New Property Value"
