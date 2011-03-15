require 'spec_helper'

describe SearchResults do
  class MockSearch
    include SearchResults
    def initialize(params = {})
      @params = {}
    end
  end

  before(:each) do
    @params = {
      "group"=>{"2"=>"any", "4"=>"any"},
      "lings"=>{"0"=>["10"], "1"=>["20"]},
      "lings_props"=>{
          "category_0_0"=>["43:Not set yet"],
          "category_1_0"=>["2:Yes"]
          },
      "properties"=>{
        "category_0_0"=>["41"],
        "category_1_0"=>["2"]
        }
      }
  end

  describe "LingFilter" do
    describe "parent_ids" do
      it "should return filtered lings_properties if parents selected" do
      end
      it "should return all lings_properties if no parents selected" do
        
      end
    end
  end

end
