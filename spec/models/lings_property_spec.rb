require 'spec_helper'

describe LingsProperty do
  it_should_validate_presence_of :ling_id, :property_id, :value
  it_should_be_createable :with => {:ling_id => 1234, :property_id => 4321, :value => 'foo'}
  it_should_belong_to :ling, :property

end
