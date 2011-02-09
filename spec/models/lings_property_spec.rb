require 'spec_helper'

describe LingsProperty do
  fixtures :lings, :properties

  describe "one-liners" do
    it_should_validate_presence_of :ling_id, :property_id, :value
    it_should_belong_to :ling, :property
    should_validate_existence_of :ling, :property
    it "must wrap finds on fixtures in an it blcok..." do
      should_be_createable :with => {:ling_id => lings(:english).id, :property_id => properties(:valid).id, :value => 'foo'}
    end
  end
end
