Feature: Data entry supported by surrounding language context

  Background:
    Given the group "Syntactic Structures"
    And the group has a maximum depth of 0

    And the following "Syntactic Structures" lings:
      | name        | depth |
      | Afrikaans   | 0     |
      | German      | 0     |
      | Spanish     | 0     |
      | French      | 0     |

    And the following "Syntactic Structures" properties:
      | property name     | ling name   | prop val    | category | depth | surety    |
      | Adjective Noun    | Afrikaans   | yes         | Grammar  | 0     | certain   | 
      | Subject Object    | Afrikaans   | no          | Grammar  | 0     | certain   |
      | Adjective Noun    | German      | no          | Grammar  | 0     | certain   |
      | Adjective Noun    | French      | N/A         | Grammar  | 0     | certain   |
      | Adjective Noun    | Spanish     | yes         | Grammar  | 0     | certain   |
      | Subject Object    | Spanish     | no          | Grammar  | 0     | certain   |
      | Noun Adjective    | Spanish     | no          | Grammar  | 0     | revisit   |
      | Object Subject    | Spanish     |             | Grammar  | 0     | certain   |

    And the following "Syntactic Structures" definitions for properties
      | property name     | definition                         |
      | Adjective Noun    | Adjective Noun definition text     |
      | Noun Adjective    | Noun Adjective definition text     |
      | Subject Object    | Subject Object definition text     |
      | Object Subject    | Object Subject definition text     |

    And the following "Syntactic Structures" examples for properties
      | ling name | property name   | example name  | description      |
      | Afrikaans | Adjective Noun  | ex1           | I speak Afrikaans|
      | German    | Adjective Noun  | ex2           | I speak German   |

    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"

#navigate to the Property Assignment in Context page
  Scenario: Signed in members can get to the Property Assignment in Context Page
    Then I should see "Afrikaans"
    When I follow "Afrikaans"
    And I press "edit-dropdown-button" within "#edit-dropdown-menu"
    Then I should see "Values" within "#edit-dropdown-menu"
    When I follow "Values" within "#edit-dropdown-menu"
    Then I should be on the Property Assignment with Context for "Afrikaans" Page

#when you arrive at the page it will be pointing to the current (in focus) property
#thus the system picks up where you left off
  Scenario: The page has a notion of a current property
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "Property Name"
    And I should see "Adjective Noun"

  Scenario: The page displays the definition of the current property
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "Property Description"
    And I should see "Adjective Noun definition text"
    And I should not see "Subject Object definition text"

#Commented out because unsure if this function is still requried
#this should perhaps be limited to a reasonably sized list
#either by arbitrarily cutting it off at some good number
#or by taking advantage of the advanced searching and clustering
#capability to display languages that are "closely" related
 # @wip
 # Scenario: The page displays languages that have the property
 #   When I am on the Property Assignment with Context for "Afrikaans" Page
 #   Then I should see "Languages with this property"
 #   And I should see "German"
 #   And I should see "Spanish"

#N.B.: this can be implemented at the presentation layer thus keeping
#the flexibility of the underlying data model intact
#in other words the user is presented with only these three values
#but the underlying data model does not restrict the values at all
  Scenario: The page gives the user a choice of three values yes - no - N/A
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "Select Value"
    And I should see "yes"
    And I should see "no"
    And I should see "N/A"
    And I should see "" within "#new_value"

#this feature is probably specific to the Terraling application
  Scenario: The page allows a user to say how certain they are
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "How sure are you about the value set?"
    And I should see "Certain"
    And I should see "Revisit"
    And I should see "Need Help"

#a step to find a button with a "name" needs to be written
  # Scenario: The page allows the user to submit their assignment
  #   When I am on the Property Assignment with Context for "Afrikaans" Page
  #   Then I should see "Save" button

  Scenario: The page displays existing examples for this property & ling
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "Examples"
    And I should see "I speak Afrikaans"

  Scenario: The page allows examples to be created and changed
    When I am on the Property Assignment with Context for "Afrikaans" Page
    Then I should see "Create Example" 
    And I should see "Change Example"

#User should be able to switch property
  Scenario: The page allows the user to switch to a different property
    When I am on the Property Assignment with Context for "Spanish" Page
    And I select "Subject Object" from "prop-select"
    Then I should see "Subject Object definition text"
    And I should not see "Adjective Noun definition text"
    When I follow "Next" within "#select-col"
    Then I should not see "Subject Object definition text"
    And I should see "Adjective Noun definition text"

#Testing the Next, Unset, and Uncertain buttons
  Scenario: The page allows the user to switch to the next property,
    the next unset property, and the next uncertain property
    When I am on the Property Assignment with Context for "Spanish" Page
    Then I should see "Adjective Noun definition text"
    When I press "Next" within "#select-col"
    Then I should see "Noun Adjective definition text"
    When I press "Next Unset" within "#select-col"
    Then I should see "Object Subject definition text"
    When I press "Next Uncertain" within "#select-col"
    Then I should see "Noun Adjective definition text"

  @wip
  @javascript
  Scenario: The page allows the user to see and minimize property description
    When I am on the Property Assignment with Context for "Spanish" Page
    Then I wait "2"
    Then I follow "prop-modal"
    # The modal takes up to 1 sec to load properly: wait 2 secs and then carry on
    Then I wait "2"
    Then I should see "Property Description" within "#property-modal"
    Then I press "minimize-prop"
    Then I should not see "#property-modal"
    Then I follow "prop-tab"
    Then I should see "Property Description" within "#property-modal"
