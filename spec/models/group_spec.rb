require 'spec_helper'

describe Group do
  describe "one-liners" do
    it_should_validate_presence_of :name
    it_should_validate_uniqueness_of :name
    it_should_have_many :lings, :properties, :lings_properties, :examples
  end

  describe "should be createable" do
    it "with a name" do
      should_be_createable :with => { :name => 'myfirstgroup' }
    end
  end
end
