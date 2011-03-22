require 'spec_helper'

describe SearchResults::SelectAllFilter do

  describe "collect_all_from_vals" do
    it "should return given vals for lings that possess all given prop_ids" do
      vals = [
        val_1 = mock_model(LingsProperty, :ling_id => 1, :property_id => 1),
        val_2 = mock_model(LingsProperty, :ling_id => 1, :property_id => 2),
        val_3 = mock_model(LingsProperty, :ling_id => 2, :property_id => 2)
      ]
      
      filter = SearchResults::SelectAllFilter
      filter.collect_all_from_vals(vals, [1,2,3]).should be_empty
      filter.collect_all_from_vals(vals, [1,2]).should == [val_1, val_2]
      filter.collect_all_from_vals(vals, [2]).should == [val_1, val_2, val_3]
    end
  end
end
