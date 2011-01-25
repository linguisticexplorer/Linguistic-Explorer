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
    And this scenario is pending
    And the following lings:
    | Ling        | 
    | English     | 
    | Spanish     | 
    When I go to the search page
    And I select "English" from the first language in the list
  
  Scenario: Visitor searches any language
  
