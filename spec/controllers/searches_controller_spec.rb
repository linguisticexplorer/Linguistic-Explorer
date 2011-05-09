require 'spec_helper'

describe SearchesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "#new" do
    it "should authorize :search on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      Search.stub(:new).and_return @search

      @ability.should_receive(:can?).with(:search, @search).and_return true

      get :new, :group_id => @group.id
    end
  end

  describe "#preview" do
    it "should authorize :search on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      Search.stub(:new).and_return @search

      @ability.should_receive(:can?).with(:search, @search).and_return true

      get :preview, :group_id => @group.id, :search => {}
    end
  end

  describe "#create" do
    it "should authorize create on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      Search.stub(:new).and_return @search

      @ability.should_receive(:can?).with(:create, @search).and_return true

      post :create, :group_id => @group.id, :search => {}
    end
  end

  describe "#show" do
    it "should load search through current_group" do
      @search = Factory(:search)
      @group = @search.group
      @searches = @group.searches
      Group.stub(:find).and_return @group

      @group.should_receive(:searches).and_return @searches

      get :show, :id => @search.id, :group_id => @group.id

      assigns(:search).should == @search
    end

    it "should authorize :search on search" do
      @group = groups(:inclusive)
      @search = Factory(:search, :group => @group)
      Search.stub(:new).and_return @search

      @ability.should_receive(:can?).with(:search, @search).and_return true

      get :show, :group_id => @group.id, :id => @search.id
    end
  end

  describe "#index" do
    describe "when logged in" do
      before do
        sign_out :user
        @user = Factory(:user, :email => "ohyeah@a.com")
        sign_in @user
      end

      it "should authorize :update on @searches" do
        @group = groups(:inclusive)
        @sc = Factory(:search, :group => @group)
        @searches = @group.searches
        Group.stub(:searches).and_return Search
        Search.stub(:by).and_return @searches

        @searches.each{ |s| @ability.should_receive(:can?).with(:update, s).and_return true }

        get :index, :group_id => @group.id
      end

      it "should load searches through current_group" do
        @search = Factory(:search)
        @group = @search.group
        @searches = @group.searches
        @searches.stub(:by).and_return @searches
        Group.stub(:find).and_return @group

        @group.should_receive(:searches).and_return @searches

        get :index, :group_id => @group.id

        assigns(:searches).should include @search
      end
    end
  end

  describe "#destroy" do
    it "should authorize destroy on @search" do
      @group = groups(:inclusive)
      @search = Factory(:search, :group => @group)
      Search.stub(:find).and_return @search

      @ability.should_receive(:can?).with(:destroy, @search).and_return true

      delete :destroy, :group_id => @group.id, :id => @search.id
    end

    it "should load @search through current_group" do
      @search = Factory(:search)
      @group = @search.group

      @group.should_receive(:searches).and_return Search.where(:group => @group)

      Group.stub(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @search.id
    end
  end
end
