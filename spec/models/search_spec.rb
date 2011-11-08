require 'spec_helper'

describe Search do

  describe "validations" do
    before(:each) do
      Search.stub!(:reached_max_limit?).and_return(false)
      @user  = User.new
      @group = Group.new
      @search = Search.new do |s|
        s.creator  = @user
        s.group = @group
      end
    end

    it_should_validate_presence_of :group, :creator, :name

    it "should validate user within max search limit" do
      Search.stub!(:reached_max_limit?).and_return(true)
      @search.valid?
      @search.should have(1).error_on(:base)
    end
  end

  describe "query" do
    before(:each) do
      builder = SearchResults::SearchFilterBuilder
      result_mock = SearchResults::ResultAdapter
      builder.stub!(:new).and_return(mock(builder, :filtered_parent_and_child_ids => [[], []]))
      @search = Factory(:search)
    end

    it "should serialize query params" do
      @search.query = { "lings" => [1,2,3], "properties" => [4,5,6] }
      @search.save

      retrieved = Search.find(@search.id)

      retrieved.query.should == { "lings" => [1,2,3], "properties" => [4,5,6] }
    end

    it "should serialize result_groups" do
      @search.result_groups = { 1 => [2,3,4], 5 => [6] }
      @search.save

      retrieved = Search.find(@search.id)

      retrieved.result_groups.should == { 1 => [2,3,4], 5 => [6] }
    end
  end

  describe "reached_max_limit?" do
    before(:each) do
      Search.stub!(:scoped).and_return(Search)
      Search.stub!(:count).and_return(0)
      @user = mock(User)
      @group = mock(Group)
    end

    it "should perform count conditions where user is user and group is group" do
      Search.should_receive(:by).with(@user).and_return(Search)
      Search.should_receive(:in_group).with(@group).and_return(Search)
      Search.should_receive(:count)
      Search.reached_max_limit?(@user, @group)
    end

    it "should return true if count for searches by user and group has reached max limit" do
      Search.stub!(:by).and_return(Search)
      Search.stub!(:in_group).and_return(Search)

      Search.stub!(:count).and_return(25)
      Search.reached_max_limit?(@user, @group).should be_true
      Search.stub!(:count).and_return(26)
      Search.reached_max_limit?(@user, @group).should be_true
    end

    it "should return true if count for searches by user and group has reached max limit" do
      Search.stub!(:by).and_return(Search)
      Search.stub!(:in_group).and_return(Search)
      Search.stub!(:count).and_return(24)
      Search.reached_max_limit?(@user, @group).should be_false
    end
  end

  describe "is_manageable_by?" do
    before(:each) do
      @user  = User.new
      @group = Group.new

      @search = Search.new do |s|
        s.creator  = @user
        s.group = @group
      end
    end
    describe "anonymous_user" do
      it "should be false" do
        @search.is_manageable_by?(@user).should be_false
      end
    end

    describe "search is new_record" do
      before(:each) do
        @creator = User.last || Factory(:user, :email => "bob-searcher@example.com")
        @search.creator = @creator
        @ability = mock(Ability, :can? => true)
        Ability.stub!(:new).and_return(@ability)
      end

      it "should be false if user is not creator" do
        @search.is_manageable_by?(Factory(:user)).should be_false
      end

      describe "user is creator" do
        it "should be true if user has group access" do
          @ability.stub!(:can?).and_return(true)
          @search.is_manageable_by?(@creator).should be_true
        end
        it "should be false if no group access" do
          @ability.stub!(:can?).and_return(false)
          @search.is_manageable_by?(@creator).should be_false
        end

      end
    end
  end
end
