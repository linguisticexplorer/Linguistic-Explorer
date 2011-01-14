require 'spec_helper'

describe LingsProperty do
  describe "validations" do
    it "should require a value" do
      LingsProperty.new(:value => '').should have(1).error_on :value
      LingsProperty.new(:value => 'valid').should have(0).errors_on :value
    end

    it "should require a ling_id" do
      LingsProperty.new(:ling_id => '').should have(1).error_on :ling_id
      LingsProperty.new(:ling_id => 1234).should have(0).errors_on :ling_id
    end

    it "should require a property_id" do
      LingsProperty.new(:property_id => '').should have(1).error_on :property_id
      LingsProperty.new(:property_id => 4321).should have(0).errors_on :property_id
    end
  end

  describe "associations" do
    xit "should belong to a ling" do
      #TODO
    end

    xit "should belong to a property" do
      #TODO
    end
  end
end
