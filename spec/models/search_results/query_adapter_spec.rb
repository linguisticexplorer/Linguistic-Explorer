require 'spec_helper'

module SearchResults

  describe QueryAdapter do
    before(:each) do
      @group = Group.new
    end
    describe "selected_property_ids" do
      before(:each) do
        params = { :properties => { "1" => [2] } }
        @query = QueryAdapter.new(@group, params)
      end
      it "should return set of properties for given category id in params" do
        @query.selected_property_ids("1").should == [2]
      end
      it "should empty array if no properties for given cat id in params" do
        @query.selected_property_ids("2").should == []
      end
    end

    describe "selected_value_pairs" do
      before(:each) do
        params = { :lings_props => { "1" => [2] } }
        @query = QueryAdapter.new(@group, params)
      end
      it "should return set of value pairs for given category id in params" do
        @query.selected_value_pairs("1").should == [2]
      end
      it "should empty array if no value pairs for given cat id in params" do
        @query.selected_value_pairs("2").should == []
      end
    end
  end
end
