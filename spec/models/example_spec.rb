require 'spec_helper'

describe Example do
  describe "one-liners" do
    it_should_belong_to :ling
#    should_validate_existence_of :ling, :allow_nil => true
  end

  describe "should be createable" do
    it "with a ling" do
      should_be_createable :with => {:ling_id => lings(:level0).id, :name => 'example-with-ling_id'}
    end

    it "without a ling" do
      should_be_createable :with => {:name => 'example-without-ling_id'}
    end
  end

  #it should probably validate attributes when those come in
end
