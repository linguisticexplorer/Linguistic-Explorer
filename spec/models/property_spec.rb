require 'spec_helper'

describe Property do
  describe "validations" do
    it "should require a name and type" do
      Property.new(:name => '', :category => 'bar').should have(1).error_on :name
      Property.new(:name => 'foo', :category => '').should have(1).error_on :category
      Property.new({:name => 'foo', :category => 'bar'}).should be_valid
    end
  end
end
