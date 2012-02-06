Feature: Forum facility

  Background:
    Given I am a visitor
    Given the following users:
      | name    | email         | password  | access_level  |
      | admin   | a@min.com     | hunter2   | admin         |
      | bob     | bob@dole.com  | hunter2   | user          |
    Given the following forum groups:
      | state   | title         | position  |
      | false   | Secret group  | 0         |
      | true    | Public group  | 1         |
    Given the following "Public group" forums:
      | state   | title               | description | position |
      | true    | Public Forum        | Public      | 0        |
      | false   | Secret Forum        | Secret      | 1        |
    Given the following "Secret group" forums:
      | state   | title               | description | position |
      | false   | Admin Forum         | Admin       | 0        |
    Given the following "Public Forum" topics from "bob@dole.com":
      | locked  | title               | body         |
      | false   | Free Topic          | Free for all |
    When I go to the home page


  Scenario: Admins can manage forum groups
    Given I am signed in as "a@min.com"
    When I follow "Forums"
    Then I should see "New Forum Group"
    Then I should see "Edit Group"
    Then I should see "Delete Group"
    And I should see "New Forum"

  Scenario: Members can not manage forum groups
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    Then I should not see "New Forum Group"
    Then I should not see "Edit Forum Group"
    Then I should not see "Delete Forum Group"
    And I should not see "New Forum"

  Scenario: Visitors can not manage forum groups
    When I follow "Forums"
    Then I should not see "New Forum Group"
    Then I should not see "Edit Forum Group"
    Then I should not see "Delete Forum Group"
    And I should not see "New Forum"

  Scenario: Admins should see secret and public forum groups
    Given I am signed in as "a@min.com"
    When I follow "Forums"
    And I should see "Secret group"
    And I should see "Public group"

  Scenario: Members should see only public forum groups
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should not see "Secret group"
    And I should see "Public group"

  Scenario: Visitors should see only public forum groups
    When I follow "Forums"
    And I should not see "Secret group"
    And I should see "Public group"

  Scenario: Admins should see secret and public forums
    Given I am signed in as "a@min.com"
    When I follow "Forums"
    And I should see "Secret group"
    And I should see "Public group"
    And I should see "Admin Forum"
    And I should see "Secret Forum"
    And I should see "Public Forum"

  Scenario: Members should see forums in public forum groups
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should not see "Secret group"
    And I should not see "Admin Forum"
    And I should see "Public group"
    And I should see "Secret Forum"
    And I should see "Public Forum"

  Scenario: Visitors should see forums in public forum groups
    When I follow "Forums"
    And I should not see "Secret group"
    And I should not see "Admin Forum"
    And I should see "Public group"
    And I should see "Secret Forum"
    And I should see "Public Forum"

  Scenario: Members should not see private forums
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Secret Forum"
    And I should see "Public Forum"
    When I follow "Secret Forum"
    Then I should see "TerraLing"
    And I should see "You are not authorized to show the requested data."

  Scenario: Visitors should not see private forums
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Secret Forum"
    And I should see "Public Forum"
    When I follow "Secret Forum"
    Then I should see "TerraLing"
    And I should see "You are not authorized to show the requested data."

  Scenario: Admins should manage forums
    Given I am signed in as "a@min.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "Public Forum"
    And I should see "New Topic"
    And I should see "Edit Forum"
    And I should see "Delete Forum"

  Scenario: Members should be able to create a new Topic
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "Public Forum"
    And I should see "New Topic"
    And I should not see "Edit Forum"
    And I should not see "Delete Forum"

  Scenario: Visitors should only read Topics
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "Public Forum"
    And I should not see "New Topic"
    And I should not see "Edit Forum"
    And I should not see "Delete Forum"

  Scenario: Members should be able to start a new Topic
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "Public Forum"
    And I should see "New Topic"
    And I follow "New Topic"
    And I fill in "Title" with "Open Topic"
    And I fill in "Body" with "This topic is open to every member of Terraling"
    And I press "submit"
    Then I should see "Open Topic"

  Scenario: Members should be able to reply to a post
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "New Topic"
    And I follow "New Topic"
    And I fill in "Title" with "Open Topic"
    And I fill in "Body" with "This topic is open to every member of Terraling"
    And I press "submit"
    Then I should see "Open Topic"
    And I should see "This topic is open to every member of Terraling"
    And I should see "Reply"
    Then I follow "Reply"
    And I fill in "Body" with "Reply to previous post"
    And I press "Submit"
    Then I should see "Reply to previous post"
    Then I should see "Post was successfully created"

  Scenario: Members should be able to quote a post
    Given I am signed in as "bob@dole.com"
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "New Topic"
    And I follow "New Topic"
    And I fill in "Title" with "Open Topic"
    And I fill in "Body" with "This topic is open to every member of Terraling"
    And I press "submit"
    Then I should see "Open Topic"
    And I should see "This topic is open to every member of Terraling"
    And I should see "Quote"
    Then I follow "Quote"
    And I press "Submit"
    Then I should see "Post was successfully created"

  Scenario: Visitors should only read Posts
    When I follow "Forums"
    And I should see "Public group"
    And I should see "Public Forum"
    And I follow "Public Forum"
    And I should see "Free Topic"
    Then I follow "Free Topic"
    And I should not see "Reply"
    And I should not see "Quote"