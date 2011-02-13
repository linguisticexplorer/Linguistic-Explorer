require 'spec_helper'

describe LingsProperty do
  describe "one-liners" do
    it_should_validate_presence_of :ling_id, :property_id, :value
    it_should_belong_to :ling, :property
    should_validate_existence_of :ling
#    should_validate_existence_of :property
  end

  describe "should be createable" do
    it "with a ling and parent of the same depth" do
      should_be_createable :with => {:ling_id => lings(:level0).id, :property_id => properties(:level0).id, :value => 'foo'}
      should_be_createable :with => {:ling_id => lings(:level1).id, :property_id => properties(:level1).id, :value => 'foo'}
    end

    it "only with lings and parents of the same depth" do
      LingsProperty.create(:ling_id => lings(:level0).id, :property_id => properties(:level1).id, :value => 'baz').should have(1).error_on :depth
      LingsProperty.create(:ling_id => lings(:level1).id, :property_id => properties(:level0).id, :value => 'bar').should have(1).error_on :depth
    end
  end
end
