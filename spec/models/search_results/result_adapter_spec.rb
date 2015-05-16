require 'rails_helper'

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
        expect(@result.type).to eq :default
      end
    end

    describe "Included Columns" do
      before(:each) do
        params = { :include => {"value_1"=>"1", "ling_0"=>"1", "depth_1"=>"1"}}
        @query = QueryAdapter.new(@group, params)
        @result = ResultAdapter.new(@query, [[1], [1]])
      end
      it "should return columns ordered" do
        expect(@result.columns).to eq [:ling_0, :value_1]
      end
      it "should say depth 1 is interesting for implication" do
        expect(@result.depth_for_implication).to eq [1]
      end
      it "should say depth 0 is not interesting for implication" do
        expect(@result.depth_for_implication).not_to eq [0]
      end
      it "should say implication depth selected is not empty" do
        expect(@result.depth_for_implication).not_to eq []
      end
    end

    describe "should contain results" do
      before(:each) do
        params = { :include => {"value_1"=>"1", "ling_0"=>"1"}}
        @query = QueryAdapter.new(@group, params)
        @result = ResultAdapter.new(@query, [[1], [1]])
      end
      it "should have results" do
        expect(@result.any?).to be_truthy
      end
      it "should return parent result" do
        expect(@result.parent).to eq [1]
      end
      it "should return child result" do
        expect(@result.child).to eq [1]
      end
    end
    describe "should contain no results" do
      before(:each) do
        @query = QueryAdapter.new(@group, {})
        @result = ResultAdapter.new(@query, [])
      end
      it "should have not results" do
        expect(@result.any?).to be_falsey
      end
      it "should return no parent result" do
        expect(@result.parent).to eq []
      end
      it "should return no child result" do
        expect(@result.child).to eq []
      end
    end

    describe "should be an implication both search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "both"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication both result" do
        expect(@result.type).to eq :implication_both
      end
    end

    describe "should be an implication antecedent search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "ante"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication antecedent result" do
        expect(@result.type).to eq :implication_ante
      end
    end

    describe "should be an implication consequent search result" do
      before(:each) do
        @query = QueryAdapter.new(@group, {:advanced_set => {"impl" => "cons"}})
        @result = ResultAdapter.new(@query, [])
      end
      it "should be a implication consequent result" do
        expect(@result.type).to eq :implication_cons
      end
    end
  end
end