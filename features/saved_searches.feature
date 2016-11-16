Feature: Save searches

  Background:
    Given the public group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | Eastern   | Demographic | 0     |
    | Property 2    | Speaker 2   | Western   | Demographic | 0     |
    | Property 3    | Sentence 1  | verb      | Linguistic  | 1     |
    | Property 4    | Sentence 2  | noun      | Linguistic  | 1     |
    And I am signed in as a member of Syntactic Structures

  Scenario: View no saved searches
    When I go to my group searches page
    Then I should see "Syntactic Structures Search History"
    Then I should see "No saved searches for Syntactic Structures"

  Scenario: View a simple saved searches
    Given I have a saved group search "My First Search"
    When I go to the Syntactic Structures search page
    When I follow "History" within "#header"
    Then I should see "My First Search"

  Scenario: No link to search history if signed out
    Given I have a saved group search "My First Search"
    When I go to the Syntactic Structures search page
    And I follow "Sign out"
    And I go to the Syntactic Structures search page
    Then I should not see "History"

  Scenario: No save search form if signed out
    When I go to the Syntactic Structures search page
    And I follow "Sign out"
    And I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Show results"
    Then I should not see "Save search results"

  Scenario: Save search
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Show results"
    And I follow "Save Search"
    Then I should see "Save search results"
    When I fill in "save-search-name" with "My First Search"
    And I press "Save"
    Then I should see "Your seach has been successfully saved!"
    When I go to the group Syntactic Structures
    And I follow "History"
    Then I should see "Syntactic Structures Search History"
    And I should see "My First Search"
    And I should not see "My Second Search"

  Scenario: See results of saved search query
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Show results"
    And I follow "Save Search"
    Then I should see "Save search results"
    When I fill in "save-search-name" with "My First Search"
    And I press "Save"
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property  | child value  |
    | Speaker 1   | Property 1      | Eastern       | Sentence 1  | Property 3      | verb         |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"

  Scenario: Export search to csv
    When I go to the Syntactic Structures search page
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I check "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Examples" within "#show_parent"
    And I check "Value" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    And I press "Show results"
    And I follow "Save Search"
    Then I should see "Save search results"
    When I fill in "save-search-name" with "My First Search"
    And I press "Save"
    And I press "Close Modal"
    And I follow "Download Results"
    Then the csv "terraling-search-results-default.csv" exists

  Scenario: Delete saved query
    Given I have a saved group search "My First Search"
    When I go to the Syntactic Structures search page
    And I follow "History" within "#header"
    And I follow "Delete"
    Then I should see "successfully deleted"
    And I should see "Syntactic Structures Search History"
    And I should not see "My First Search"

  Scenario: Warning after 25 saved searches
    Given I have 25 saved group searches
    When I go to the Syntactic Structures search page
    Then I should see "reached the system limit for saved searches"
    When I press "Show results"
    Then I should see "reached the system limit for saved searches"
    And I should not see "Save search results"

  Scenario: Save search at limit
    Given I have 24 saved group searches
    When I go to the Syntactic Structures search page
    And I press "Show results"
    And I follow "Save Search"
    And I fill in "save-search-name" with "Search 25"
    And I press "Save"
    And I go to the group Syntactic Structures
    And I follow "History"
    Then I should see "Search 25"

  Scenario: Error on search
    When I go to the Syntactic Structures search page
    And I press "Show results"
    And I follow "Save Search"
    And I fill in "save-search-name" with ""
    Then I press "Save"
    And I should see "can't be blank"

  Scenario: Regenerate results of saved search query
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Sentence 1" from "Sentences"
    And I press "Show results"
    And I follow "Save Search"
    Then I should see "Save search results"
    When I fill in "save-search-name" with "My First Search"
    And I press "Save"
    Then I go to the Syntactic Structures search page
    When I select "Speaker 2" from "Speakers"
    And I select "Sentence 2" from "Sentences"
    And I press "Show results"
    And I follow "History"
    And I follow "My First Search"
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property  | child value  |
    | Speaker 1   | Property 1      | Eastern       | Sentence 1  | Property 3      | verb         |
    And I should not see "Speaker 2"
    And I should not see "Sentence 2"


  Scenario: No save option for Cross Search
    When I go to the Syntactic Structures search page
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I choose "Cross" within "#demographic_properties"
    And I press "Show results"
    Then I should not see "Save search results"

  Scenario: No save option for Compare Search
    When I go to the Syntactic Structures search page
    And I select "Speaker 1" from "Speakers"
    And I select "Speaker 2" from "Speakers"
    And I choose "Compare" within "#speakers"
    And I press "Show results"
    Then I should not see "Save search results"

  Scenario: No save option for Universal Implication Search
    When I go to the Syntactic Structures search page
    And I choose "Both" within "#advanced_set"
    And I select "Property 1" from "Demographic Properties"
    And I select "Property 2" from "Demographic Properties"
    And I press "Show results"
    Then I should not see "Save search results"