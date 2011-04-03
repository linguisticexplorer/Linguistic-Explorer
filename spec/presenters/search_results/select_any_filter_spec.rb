require 'spec_helper'

module SearchResults

  describe SelectAnyFilter do
    before(:each) do
      @params = stub({
        :depth_0_ling_ids => [1],
        :depth_1_ling_ids => [2],
        :depth_0_prop_ids => [3],
        :depth_1_prop_ids => [4],
        :has_depth?       => true
      })

      LingsProperty.stub!(:select_ids).and_return(LingsProperty)
      LingsProperty.stub!(:where).and_return([])

      @filter = SelectAnyFilter.new(@params)
    end
    describe "depth_0_vals" do
      it "should select lings property with depth 0 ling and prop ids" do
        LingsProperty.should_receive(:where).with({
          :ling_id => [1],
          :property_id => [3]
        }).and_return([:a, :b])

        @filter.depth_0_vals.should == [:a, :b]
      end

      it "should not pass empty set of ling ids" do
        @filter.params.stub!(:depth_0_ling_ids).and_return([])
        LingsProperty.should_receive(:where).with({
          :property_id => [3]
        })

        @filter.depth_0_vals
      end

      it "should not pass empty set of property ids" do
        @filter.params.stub!(:depth_0_prop_ids).and_return([])
        LingsProperty.should_receive(:where).with({
          :ling_id => [1]
        })

        @filter.depth_0_vals
      end
    end
    describe "depth_1_vals" do
      it "should select lings property with depth 0 ling and prop ids" do
        LingsProperty.should_receive(:where).with({
          :ling_id => [2],
          :property_id => [4]
        }).and_return([:a, :b])

        @filter.depth_1_vals.should == [:a, :b]
      end

      it "should not pass empty set of ling ids" do
        @filter.params.stub!(:depth_1_ling_ids).and_return([])
        LingsProperty.should_receive(:where).with({
          :property_id => [4]
        })

        @filter.depth_1_vals
      end

      it "should not pass empty set of property ids" do
        @filter.params.stub!(:depth_1_prop_ids).and_return([])
        LingsProperty.should_receive(:where).with({
          :ling_id => [2]
        })

        @filter.depth_1_vals
      end

      it "should not make query if params has no depth" do
        @filter.params.stub!(:has_depth?).and_return(false)
        LingsProperty.should_not_receive(:where)

        @filter.depth_1_vals
      end
    end
  end

end
