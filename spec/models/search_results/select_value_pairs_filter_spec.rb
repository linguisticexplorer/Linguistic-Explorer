require 'rails_helper'

module SearchResults

  describe SelectValuePairsFilter do
    describe "non cross search scenario" do
      before(:each) do
        @query = double({
          :depth_0_ling_ids => [1],
          :depth_1_ling_ids => [2],
          :depth_0_prop_ids => [3],
          :depth_1_prop_ids => [4],
          :has_depth?       => true,
          :group_id         => 123,
          :is_cross_search? => false
        })

        allow(LingsProperty).to receive_message_chain(:select_ids).and_return(LingsProperty)
        allow(LingsProperty).to receive_message_chain(:where).and_return([])

        @filter = SelectValuePairsFilter.new(@query)
      end
      describe "depth_0_vals" do
        it "should select lings property with depth 0 ling and prop ids" do
          expect(LingsProperty).to receive(:where).with({
            :property_value => 
          }).and_return([:a, :b])

          expect(@filter.depth_0_vals).to eq [:a, :b]
        end

        it "should not pass empty set of ling ids" do
          allow(@filter.query).to receive_message_chain(:depth_0_ling_ids).and_return([])
          expect(LingsProperty).to receive(:where).with({
            :group_id => 123,
            :property_id => [3]
          })

          @filter.depth_0_vals
        end

        it "should not pass empty set of property ids" do
          allow(@filter.query).to receive_message_chain(:depth_0_prop_ids).and_return([])
          expect(LingsProperty).to receive(:where).with({
            :group_id => 123,
            :ling_id => [1]
          })

          @filter.depth_0_vals
        end
      end
      describe "depth_1_vals" do
        it "should select lings property with depth 0 ling and prop ids" do
          expect(LingsProperty).to receive(:where).with({
            :group_id => 123,
            :ling_id => [2],
            :property_id => [4]
          }).and_return([:a, :b])

          expect(@filter.depth_1_vals).to eq [:a, :b]
        end

        it "should not pass empty set of ling ids" do
          allow(@filter.query).to receive_message_chain(:depth_1_ling_ids).and_return([])
          expect(LingsProperty).to receive(:where).with({
            :group_id => 123,
            :property_id => [4]
          })

          @filter.depth_1_vals
        end

        it "should not pass empty set of property ids" do
          allow(@filter.query).to receive_message_chain(:depth_1_prop_ids).and_return([])
          expect(LingsProperty).to receive(:where).with({
            :group_id => 123,
            :ling_id => [2]
          })

          @filter.depth_1_vals
        end

        it "should not make query if query has no depth" do
          allow(@filter.query).to receive_message_chain(:has_depth?).and_return(false)
          expect(LingsProperty).not_to receive(:where)

          @filter.depth_1_vals
        end
      end
    end
  end

end