Feature: Show filtered search columns

  Background:
    Given I am a visitor
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    And the following "Syntactic Structures" lings:
    | name        | parent      | depth |
    | Speaker 1   |             | 0     |
    | Speaker 2   |             | 0     |
    | Speaker 3   |             | 0     |
    | Sentence 1  | Speaker 1   | 1     |
    | Sentence 2  | Speaker 2   | 1     |
    | Sentence 3  | Speaker 1   | 1     |
    And the following "Syntactic Structures" properties:
    | property name | ling name   | prop val  | category    | depth |
    | Property 1    | Speaker 1   | PropVal 1 | Demographic | 0     |
    | Property 2    | Speaker 2   | PropVal 2 | Demographic | 0     |
    | Property 3    | Sentence 1  | PropVal 3 | Linguistic  | 1     |
    | Property 4    | Sentence 2  | PropVal 4 | Linguistic  | 1     |
    | Property 5    | Sentence 3  | PropVal 5 | Linguistic  | 1     |
    | Property 6    | Sentence 1  | PropVal 3 | Linguistic  | 1     |
    | Property 7    | Speaker 3   | PropVal 6 | Demographic | 0     |
    When I go to the Syntactic Structures search page

  Scenario: Choose one Speaker, show Speakers only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | depth    |
    | Speaker 1     | parent   |
    And I should not see "Sentences" within "#search_results"
    And I should not see "Property" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show Speakers and Sentences only
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 2 search result rows
    Then I should see the following search results:
    | Lings         | depth    |
    | Speaker 1     | parent   |
    | Sentence 1    | child    |
    | Speaker 1     | parent   |
    | Sentence 3    | child    |
    And I should not see "Sentences" within "#search_results"
    And I should not see "Property" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Sentence, show Speakers and Sentences only
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Sentence 1" from "Sentences"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | depth    |
    | Speaker 1     | parent   |
    | Sentence 1    | child    |
    And I should not see "Property" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Sentence, show Sentences only
    When I uncheck "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Sentence 1" from "Sentences"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | depth    |
    | Sentence 1    | child    |
    And I should not see "Speakers" within "#search_results"
    And I should not see "Property" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Sentence, show Sentences and Properties only
    When I uncheck "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I check "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Sentence 1" from "Sentences"
    Then I press "Show results"
    Then I should see 2 search result rows
    Then I should see the following search results:
    | Lings         | Properties | depth    |
    | Sentence 1    | Property 3 | child    |
    | Sentence 1    | Property 6 | child    |
    And I should not see "Speakers" within "#search_results"
    And I should not see "Value" within "#search_results"
    And I should not see "PropVal" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Sentence, show Sentences and Values only
    When I uncheck "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Sentence 1" from "Sentences"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | Values    | depth    |
    | Sentence 1    | PropVal 3 | child    |
    And I should not see "Speakers" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show Speakers and Values only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I check "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | Values    | depth    |
    | Speaker 1     | PropVal 1 | parent   |
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show Speakers and Sentences-Values only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 2 search result rows
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show Sentences-Values only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 2 search result rows
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show Sentences only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 2 search result rows
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Sentence, show Speakers and Sentences-Values only
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Sentence 1" from "Sentences"
    Then I press "Show results"
    Then I should see 1 search result rows
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker without children, select all columns
    When I check "Speakers" within "#show_parent"
    And I check "Sentences" within "#show_child"
    And I check "Properties" within "#show_parent"
    And I check "Properties" within "#show_child"
    And I check "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I check "Examples" within "#show_parent"
    And I check "Examples" within "#show_child"
    And I select "Speaker 3" from "Speaker"
    Then I press "Show results"
    Then I should see no search result rows

  Scenario: Choose one Speaker without children, select parent columns
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I check "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I check "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I check "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 3" from "Speaker"
    Then I press "Show results"
    Then I should see 1 search result rows
    Then I should see the following search results:
    | Lings         | Values    | Properties     | depth    |
    | Speaker 3     | PropVal 6 | Property 7     | parent   |

  Scenario: Choose one Speaker, show parent Values only
    When I uncheck "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I check "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 1 search result rows
    And I should not see "Speakers" within "#search_results"
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Choose one Speaker, show children Values only
    When I uncheck "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I check "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Speaker 1" from "Speakers"
    Then I press "Show results"
    Then I should see 2 search result rows
    And I should not see "Speakers" within "#search_results"
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"

  Scenario: Visitor makes a Special Search, but choose just Speaker column
    When I check "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Properties" within "#show_parent"
    And I uncheck "Properties" within "#show_child"
    And I uncheck "Value" within "#show_parent"
    And I uncheck "Value" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    And I select "Property 3" from "Linguistic Properties"
    And I select "Property 6" from "Linguistic Properties"
    And I choose "Cross" within "#linguistic_properties"
    Then I press "Show results"
    Then I should see 1 search result rows
    And I should not see "Speakers" within "#search_results"
    And I should not see "Sentences" within "#search_results"
    And I should not see "Properties" within "#search_results"
    And I should not see "Examples" within "#search_results"