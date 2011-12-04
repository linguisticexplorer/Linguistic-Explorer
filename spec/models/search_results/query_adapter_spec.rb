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

    describe "included_columns" do
      before(:each) do
        params = { :include => {"value_1"=>"1", "ling_0"=>"1", "depth_1"=>"1"}}
        @query = QueryAdapter.new(@group, params)
      end
      it "should return columns ordered" do
        @query.included_columns.should == [:ling_0, :value_1]
      end
      it "should say depth 1 is interesting" do
        @query.is_depth_1_interesting?.should be_true
      end
      it "should say depth 1 is interesting for implication" do
        @query.depth_of_implication.should == [1]
      end
    end

    describe "is not cross search?" do
      before(:each) do
        params = { :property_set => {"1" => "all", "2" => "any"}}
        @query = QueryAdapter.new(@group, params)
      end
      it "should assert that is not a cross search" do
        @query.is_cross_search?.should be_false
      end
    end

    describe "is not compare search?" do
      before(:each) do
        params = { :property_set => {"1" => "all", "2" => "any"}}
        @query = QueryAdapter.new(@group, params)
      end
      it "should assert that is not a cross search" do
        @query.is_compare_search?.should be_false
      end
    end

    describe "is implication both search?" do
      before(:each) do
        params = { :advanced_set => {"impl" => "both"}}
        @query = QueryAdapter.new(@query, params)
      end
      it "should assert that is a implication both search" do
        @query.is_both_implication_search?.should be_true
      end
      it "should assert that is a generic implication search" do
        @query.is_implication_search?.should be_true
      end
    end

    describe "is implication antecedent search?" do
      before(:each) do
        params = { :advanced_set => {"impl" => "ante"}}
        @query = QueryAdapter.new(@query, params)
      end
      it "should assert that is a implication antecedent search" do
        @query.is_antecedent_implication_search?.should be_true
      end
      it "should assert that is a generic implication search" do
        @query.is_implication_search?.should be_true
      end
    end

    describe "is implication consequent search?" do
      before(:each) do
        params = { :advanced_set => {"impl" => "cons"}}
        @query = QueryAdapter.new(@query, params)
      end
      it "should assert that is a implication consequent search" do
        @query.is_consequent_implication_search?.should be_true
      end
      it "should assert that is a generic implication search" do
        @query.is_implication_search?.should be_true
      end
    end

  end
end
