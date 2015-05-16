require 'rails_helper'

describe StoredValue do
  class StorableMock
    def storable_keys; ["foo", "bar"] end
    def self.reflect_on_all_associations(arg); [] end
  end

  describe "one-liners" do
    it { expect validate_presence_of :key }
    it { expect validate_presence_of :value }
    it { expect validate_presence_of :storable }
    it { expect belong_to :storable }
  end

  it "should validate that its key is among the 'storable values' list for its storable" do
    fake_storable = StorableMock.new
    stored_value = StoredValue.new(:key => "not_a_key", :value => "quux")
    allow(stored_value).to receive_message_chain(:storable).and_return fake_storable
    stored_value.save
    expect(stored_value.errors_on(:key)).to include "must be a storable key valid for StorableMock"
  end
end
