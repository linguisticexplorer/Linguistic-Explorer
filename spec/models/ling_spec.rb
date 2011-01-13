require 'spec_helper'

describe Ling do
  describe "validations" do
    it "should require a name" do
      Ling.new(:name => '').should_not be_valid
      Ling.new(:name => 'foo').should be_valid
    end

  end
end
