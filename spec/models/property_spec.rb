require 'spec_helper'

describe Property do
  describe "validations" do
    it "should require a name and type" do
      Property.new(:name => '', :type => 'bar').should have(1).error_on :name
      Property.new(:name => 'foo', :type => '').should have(1).error_on :type

      Property.new(:name => 'foo', :type => 'bar').should be_valid
    end
  end
end
