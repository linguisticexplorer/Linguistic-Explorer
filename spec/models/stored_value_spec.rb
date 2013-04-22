require 'spec_helper'

describe StoredValue do
  class StorableMock
    def storable_keys; ["foo", "bar"] end
    def self.reflect_on_all_associations(arg); [] end
  end

  describe "one-liners" do
    # it_should_validate_presence_of :key, :value, :storable
    # it_should_belong_to :storable
    it { should validate_presence_of :key }
    it { should validate_presence_of :value }
    it { should validate_presence_of :storable }
    it { should belong_to :storable }
    # Removed at the moment because the standard gem doesn't offer this method...
    # should_validate_existence_of :storable
  end

  it "should validate that its key is among the 'storable values' list for its storable" do
    fake_storable = StorableMock.new
    stored_value = StoredValue.new(:key => "not_a_key", :value => "quux")
    stored_value.stub(:storable).and_return fake_storable
    stored_value.save
    stored_value.errors_on(:key).should include "must be a storable key valid for StorableMock"
  end
end
