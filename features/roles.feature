Feature: Roles management

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

  Scenario: Signed in as a group admin can change settings of Syntactic Structures
    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I should see "Edit" icon within "#title"
    And I should see "Trash" icon within "#title"
    And I should see "Plus" icon within "#intro"

  Scenario: Signed in as a member can't change settings of Syntactic Structures
    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I should not see "Edit" icon within "#title"
    And I should not see "Trash" icon within "#title"
    And I should not see "Plus" icon within "#intro"


  Scenario: Signed in as a group admin can add new ling
    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Lings"
    And I should see "Plus" icon within "#main"

  Scenario: Signed in as a member can't add new ling
    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Lings"
    And I should not see "Plus" icon within "#main"


  Scenario: Signed in as a group admin can add, delete, edit ling properties
    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Properties"
    And I should see "Plus" icon within "#main"
    And I should see "Edit" icon within "#pagination_table"
    And I should see "Trash" icon within "#pagination_table"

  Scenario: Signed in as a member can't add, delete, edit ling properties
    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Properties"
    And I should not see "Plus" icon within "#main"
    And I should not see "Edit" icon within "#pagination_table"
    And I should not see "Trash" icon within "#pagination_table"


  Scenario: Signed in as a group admin can add, delete, edit ling properties
    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Members"
    And I should see "Plus" icon within "#main"

  Scenario: Signed in as a member can add a new member
    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow "Members"
    And I should not see "Plus" icon within "#main"


  Scenario: Signed in as a group admin can get to the Property Assignment in Context Page
    When I am signed in as a admin of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    Then I should see "Afrikaans"
    When I follow "Afrikaans"
    Then I should not see "edit-dropdown-button"
    And I should see "Actions" within "#pagination_table"
    And I should see "Plus" icon within "#pagination_table"
    And I should see "Edit" icon within "#pagination_table"
    And I should see "Trash" icon within "#pagination_table"

  Scenario: Signed in as a member can't get to the Property Assignment in Context Page
    When I am signed in as a member of Syntactic Structures
    And I go to the group Syntactic Structures
    And I follow the "Ling" with depth "0" model link for the group "Syntactic Structures"
    Then I should see "Afrikaans"
    When I follow "Afrikaans"
    Then I should not see "edit-dropdown-button"
    And I should not see "Actions" within "#pagination_table"
    And I should not see "Plus" icon within "#pagination_table"
    And I should not see "Edit" icon within "#pagination_table"
    And I should not see "Trash" icon within "#pagination_table"
