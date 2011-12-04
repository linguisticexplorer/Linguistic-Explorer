require 'spec_helper'

module SearchResults

  describe ResultAdapter do
    before(:each) do
      @group = Group.new
    end

    describe "default type of search" do
      before(:each) do
        params = { :property_set => {"1" => "any", "2" => "all"}}
        @query = QueryAdapter.new(@group, params)
        @result = ResultAdapter.new(@query, [])
      end
      it "should return the default type of the search" do
        @result.type.should == :default
      end
    end

    describe "Included Columns" do
      before(:each) do
        params = { :include => {"value_1"=>"1", "ling_0"=>"1", "depth_1"=>"1"}}
        @query = QueryAdapter.new(@group, params)
        @result = ResultAdapter.new(@query, [[1], [1]])
      end
      it "should return columns ordered" do
        @result.columns.should == [:ling_0, :value_1]
      end
      it "should say depth 1 is interesting for implication" do
        @result.depth_for_implication.should == [1]
      end
    end

    describe "should contain results" do
      before(:each) do
        params = { :include => {"value_1"=>"1", "ling_0"=>"1"}}
        @query = QueryAdapter.new(@group, params)
        @result = ResultAdapter.new(@query, [[1], [1]])
      end
      it "should have results" do
        @result.any?.should be_true
      end
      it "should return parent result" do
        @result.parent == [1]
      end
      it "should return child result" do
        @result.child == [1]
      end
    end
    describe "should contain no results" do
      before(:each) do
        @query = QueryAdapter.new(@group, {})
        @result = ResultAdapter.new(@query, [])
      end
      it "should have not results" do
        @result.any?.should be_false
      end
      it "should return no parent result" do
        @result.parent == []
      end
      it "should return no child result" do
        @result.child == []
      end
    end

    describe "should be an implication both search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "both"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication both result" do
        @result.type.should == :implication_both
      end
    end

    describe "should be an implication antecedent search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "ante"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication antecedent result" do
        @result.type.should == :implication_ante
      end
    end

    describe "should be an implication consequent search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "cons"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication consequent result" do
        @result.type.should == :implication_cons
      end
    end
  end
end