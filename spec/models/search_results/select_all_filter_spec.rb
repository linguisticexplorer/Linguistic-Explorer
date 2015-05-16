require 'rails_helper'

module SearchResults
  describe SelectAllPropertyStrategy do

    describe "collect_all_from_vals" do
      it "should return given vals for lings that possess all given prop_ids" do
        vals = [
          val_1 = mock_model(LingsProperty, :ling_id => 1, :property_id => 1),
          val_2 = mock_model(LingsProperty, :ling_id => 1, :property_id => 2),
          val_3 = mock_model(LingsProperty, :ling_id => 2, :property_id => 2)
        ]

        strategy = SelectAllPropertyStrategy.new(double(SelectAllFilter))
        expect(strategy.collect_all_from_vals(vals, [1,2,3])).to be_empty
        expect(strategy.collect_all_from_vals(vals, [1,2])).to eq [val_1, val_2]
        expect(strategy.collect_all_from_vals(vals, [2])).to eq [val_1, val_2, val_3]
      end
    end
  end
end
