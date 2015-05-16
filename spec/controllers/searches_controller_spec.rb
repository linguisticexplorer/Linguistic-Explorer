require 'rails_helper'

describe SearchesController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "#new" do
    it "should authorize :search on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      allow(Search).to receive_message_chain(:new).and_return @search

      expect(@ability).to receive(:can?).with(:search, @search).and_return true

      get :new, :group_id => @group.id
    end
  end

  describe "#preview" do
    it "should authorize :search on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      allow(Search).to receive_message_chain(:new).and_return @search

      expect(@ability).to receive(:can?).with(:search, @search).and_return true

      get :preview, :group_id => @group.id, :search => {}
    end
  end

  describe "#create" do
    it "should authorize create on @search" do
      @group = groups(:inclusive)
      @search = Search.new
      allow(Search).to receive_message_chain(:new).and_return @search

      expect(@ability).to receive(:can?).with(:create, @search).and_return true

      post :create, :group_id => @group.id, :search => {}
    end
  end

  describe "#show" do
    it "should load search through current_group" do
      @search = FactoryGirl.create(:search)
      @group = @search.group
      @searches = @group.searches
      allow(Group).to receive_message_chain(:find).and_return @group

      expect(@group).to receive(:searches).and_return @searches

      get :show, :id => @search.id, :group_id => @group.id

      expect(assigns(:search)).to eq @search
    end

    it "should authorize :search on search" do
      @group = groups(:inclusive)
      @search = FactoryGirl.create(:search, :group => @group)
      allow(Search).to receive_message_chain(:new).and_return @search

      expect(@ability).to receive(:can?).with(:search, @search).and_return true

      get :show, :group_id => @group.id, :id => @search.id
    end
  end

  describe "#index" do
    describe "when logged in" do
      before do
        sign_out :user
        @user = FactoryGirl.create(:user, :email => "ohyeah@a.com")
        sign_in @user
      end

      it "should authorize :update on @searches" do
        @group = groups(:inclusive)
        @sc = FactoryGirl.create(:search, :group => @group)
        @searches = @group.searches
        allow(Group).to receive_message_chain(:searches).and_return Search
        allow(Search).to receive_message_chain(:by).and_return @searches

        @searches.each{ |s| expect(@ability).to receive(:can?).with(:update, s).and_return true }

        get :index, :group_id => @group.id
      end

      it "should load searches through current_group" do
        @search = FactoryGirl.create(:search)
        @group = @search.group
        @searches = @group.searches
        allow(@searches).to receive_message_chain(:by).and_return @searches
        allow(Group).to receive_message_chain(:find).and_return @group

        expect(@group).to receive(:searches).and_return @searches

        get :index, :group_id => @group.id

        expect(assigns(:searches)).to include @search
      end
    end
  end

  describe "#destroy" do
    it "should authorize destroy on @search" do
      @group = groups(:inclusive)
      @search = FactoryGirl.create(:search, :group => @group)
      allow(Search).to receive_message_chain(:find).and_return @search

      expect(@ability).to receive(:can?).with(:destroy, @search).and_return true

      delete :destroy, :group_id => @group.id, :id => @search.id
    end

    it "should load @search through current_group" do
      @search = FactoryGirl.create(:search)
      @group = @search.group

      expect(@group).to receive(:searches).and_return Search.where(:group_id => @group.id)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @search.id
    end
  end
end
