require 'spec_helper'

describe LingsProperty do
  it_should_validate_presence_of :ling_id, :property_id, :value
  it_should_be_createable :with => {:ling_id => "1234", :property_id => "4321", :value => 'foo'}
  it_should_belong_to :ling, :property

  xit "should validate_existence_of ling and property" do
    lp = LingsProperty.create(:value => "bad ling", :ling_id => 0, :property_id => Property.first.id)
    lp.should have(1).error_on "ling_id"
    lp2 = LingsProperty.create(:value => "bad prop", :ling_id => Ling.first.id, :property_id => 0)
    lp2.should have(1).error_on "property_id"
  end
end
