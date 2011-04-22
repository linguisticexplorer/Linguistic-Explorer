require 'spec_helper'

describe Search do

  describe "validations" do
    before(:each) do
      Search.stub!(:reached_max_limit?).and_return(false)
      @user  = User.new
      @group = Group.new
      @search = Search.new do |s|
        s.user  = @user
        s.group = @group
      end
    end
    it_should_validate_presence_of :group, :user, :name
    it "should validate user within max search limit" do
      Search.stub!(:reached_max_limit?).and_return(true)
      @search.valid?
      @search.should have(1).error_on(:base)
    end
    it "should validate user a member of group if group private" do
      @group.privacy = Group::PRIVATE
      @user.stub!(:member_of?).with(@group).and_return(false)
      @search.valid?
      @search.should have(1).error_on(:base)
    end
  end

  describe "query" do
    it "should serialize query params" do
      search = Factory(:search)
      search.query = { "lings" => [1,2,3], "properties" => [4,5,6] }
      search.save

      retrieved = Search.find(search.id)

      retrieved.query.should == { "lings" => [1,2,3], "properties" => [4,5,6] }
    end
  end

  describe "reached_max_limit?" do
    before(:each) do
      Search.stub!(:where).and_return(Search)
      Search.stub!(:count).and_return(0)
      @user = mock(User)
      @group = mock(Group)
    end

    it "should perform count conditions where user is user and group is group" do
      Search.should_receive(:where).with(:user => @user, :group => @group).and_return(Search)
      Search.should_receive(:count)
      Search.reached_max_limit?(@user, @group)
    end
    it "should return true if count for searches by user and group has reached max limit" do
      Search.stub!(:count).and_return(25)
      Search.reached_max_limit?(@user, @group).should be_true
      Search.stub!(:count).and_return(26)
      Search.reached_max_limit?(@user, @group).should be_true
    end
    it "should return true if count for searches by user and group has reached max limit" do
      Search.stub!(:count).and_return(24)
      Search.reached_max_limit?(@user, @group).should be_false
    end
  end
end
