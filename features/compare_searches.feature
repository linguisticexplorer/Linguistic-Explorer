Feature: Compare searches

  Background:

    Given I am signed in as "bob@example.com"
    And the group "Syntactic Structures"
    And the group "Syntactic Structures" with the following ling names:
    | ling0_name  | ling1_name  |
    | Speaker     | Sentence    |
    And the following results for the group search "First search":
    | parent ling | parent property | parent value  | child ling  | child property | child value |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1 |
    | Speaker 2   | Property 2      | parent val 2  | Sentence 2  | Property 12    | child val 2 |
    And the following results for the group search "Second search":
    | parent ling | parent property | parent value  | child ling  | child property | child value |
    | Speaker 1   | Property 3      | parent val 3  | Sentence 3  | Property 13    | child val 3 |
    | Speaker 2   | Property 2      | parent val 2  | Sentence 2  | Property 12    | child val 2 |
    When I go to the group Syntactic Structures
    And I follow "History"

  Scenario: Union two saved searches
    When I select "union" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 3 search result rows
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1  |
    | Speaker 1   | Property 3      | parent val 3  | Sentence 3  | Property 13    | child val 3  |
    | Speaker 2   | Property 2      | parent val 2  | Sentence 2  | Property 12    | child val 2  |

  Scenario: Intersect two saved searches
    When I select "intersection" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 1 search result row
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 2   | Property 2      | parent val 2  | Sentence 2  | Property 12    | child val 2  |

  Scenario: Difference of first search with second search
    When I select "difference" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 1 search result row
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1  |

  Scenario: Difference of second search with first search
    When I select "difference" from "Perform"
    And I select "Second search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see 1 search result row
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 1   | Property 3      | parent val 3  | Sentence 3  | Property 13    | child val 3 |

  Scenario: Exclusion of first search with second search
    When I select "exclusion" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 2 search result rows
    And I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1  |
    | Speaker 1   | Property 3      | parent val 3  | Sentence 3  | Property 13    | child val 3  |

  Scenario: Exclusion of second search with first search
    When I select "exclusion" from "Perform"
    And I select "Second search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see 2 search result rows
    And I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value  |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1  |
    | Speaker 1   | Property 3      | parent val 3  | Sentence 3  | Property 13    | child val 3  |

  Scenario: Nothing selected
    When I press "Go"
    Then I should see "Please select a comparison and two searches"

  Scenario: Union with self, no new results
    When I select "union" from "Perform"
    And I select "First search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see 2 search result rows
    Then I should see the following grouped search results:
    | parent ling | parent property | parent value  | child ling  | child property | child value |
    | Speaker 1   | Property 1      | parent val 1  | Sentence 1  | Property 11    | child val 1 |
    | Speaker 2   | Property 2      | parent val 2  | Sentence 2  | Property 12    | child val 2 |

  Scenario: Difference with self, no results
    When I select "difference" from "Perform"
    And I select "First search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see no search result rows

  Scenario: Intersection with self, no new results
    When I select "intersection" from "Perform"
    And I select "First search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see 2 search result rows

  Scenario: Exclusion with self, no results
    When I select "exclusion" from "Perform"
    And I select "First search" from "of"
    And I select "First search" from "with"
    And I press "Go"
    Then I should see no search result rows

  Scenario: Comparison based on included columns: properties and values
    When I uncheck "Speakers" within "#show_parent"
    And I uncheck "Sentences" within "#show_child"
    And I uncheck "Examples" within "#show_parent"
    And I uncheck "Examples" within "#show_child"
    When I select "intersection" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 1 search result row
    And I should see "Property 2"
    And I should see "parent val 2"
    And I should see "Property 12"
    And I should see "child val 2"
    And I should not see "Lings" within "#search_results"
    And I should not see "Example" within "#search_results"

  Scenario: Save compared search
    When I select "union" from "Perform"
    And I select "First search" from "of"
    And I select "Second search" from "with"
    And I press "Go"
    Then I should see 3 search result rows
    When I follow "Save Search"
    Then I should see "Save search results"
    When I fill in "save-search-name" with "Third Search"
    And I press "Save"
    When I go to the group Syntactic Structures
    And I follow "History"
    Then I should see "Syntactic Structures Search History"
    And I should see "Third Search"