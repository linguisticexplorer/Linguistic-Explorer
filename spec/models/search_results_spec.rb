require 'spec_helper'

describe SearchResults do
  # class MockSearch
  #   include SearchResults
  #   def initialize(params = {})
  #     @params = {}
  #   end
  # end
  #
  # before(:each) do
  #   @params = {
  #     "group"=>{"2"=>"any", "4"=>"any"},
  #     "lings"=>{"0"=>["10"], "1"=>["20"]},
  #     "lings_props"=>{
  #         "category_0_0"=>["43:Not set yet"],
  #         "category_1_0"=>["2:Yes"]
  #         },
  #     "properties"=>{
  #       "category_0_0"=>["41"],
  #       "category_1_0"=>["2"]
  #       }
  #     }
  # end

  before(:each) do
    @search = Search.new
  end

  describe "result_rows" do
    it "should be constructed from result_groups to rows of parent/child ids" do
      @search.result_groups = {
        1 => [2,3,4],
        5 => [6]
      }
      @search.result_rows.should == [
        [1, 2],
        [1, 3],
        [1, 4],
        [5, 6]
      ]
    end
  end

  describe "result_rows=" do
    it "should set result_groups as hash of parent_ids => [related child_ids]" do
      @search.result_rows = [
        [1, 2],
        [1, 3],
        [1, 4],
        [5, 6]
      ]
      @search.result_groups.should == {
        1 => [2,3,4],
        5 => [6]
      }
    end
  end
end
