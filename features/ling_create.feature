Feature: Creating a Ling

  Background:
    Given the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |

  Scenario: Visitor can create a ling
    Given I am a visitor
    And I go to the group Syntactic Structures
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    When I follow "New Speaker"
    Then I should see "New Speaker"
    When I fill in "English" for "Name"
    And I fill in "0" for "Depth"
    And I press "Create Ling"
    And show me the page
    Then I should see "Speaker was successfully created"
    And I should see "English"
