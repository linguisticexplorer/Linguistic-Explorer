require 'spec_helper'

describe Search do

  describe "validations" do
    it_should_validate_presence_of :group, :user, :name
  end

  describe "params" do
    it "should serialize params" do
      search = Factory(:search)
      search.query = { "lings" => [1,2,3], "properties" => [4,5,6] }
      search.save

      retrieved = Search.find(search.id)

      retrieved.query.should == { "lings" => [1,2,3], "properties" => [4,5,6] }
    end
  end
end
