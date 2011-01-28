Feature: Search with Any
  
  Background: 
    Given I am a visitor
    
    # Ling[] Prop[] Val[]
    # selector for ling
    # selector for prop
    # selector for val
    # choosing any
    # choosing all
    
  Scenario: Visitor searches any language
    And the following lings:
    | name        | 
    | English     | 
    | Spanish     | 
    | German      | 
    When I go to the new search page
    And I check "Include language"
    And I select "English" from "Languages"
    And I press "Search"
    Then I should see "Results"
    And I should see "English"
    And I should not see "Spanish"
  
  Scenario: Visitor searches any language
  
