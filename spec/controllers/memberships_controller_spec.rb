require 'rails_helper'

describe MembershipsController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@memberships should load through the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:memberships).and_return @group.memberships

      get :index, :group_id => @group.id
    end

    describe "assigns" do
      it "@memberships should contain memberships for the passed group" do
        @group = groups(:inclusive)
        membership = FactoryGirl.create(:membership, :group => @group)

        get :index, :group_id => @group.id, :letter => "all"

        expect(assigns(:memberships)).to include membership
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@membership should match the passed id" do
        @group = groups(:inclusive)
        membership = FactoryGirl.create(:membership, :group => @group)

        get :show, :id => membership.id, :group_id => @group.id

        expect(assigns(:membership)).to eq membership
      end
    end

    it "@membership should be load through current_group" do
      @group = groups(:inclusive)
      @membership = FactoryGirl.create(:membership, :group => @group)

      allow(Group).to receive_message_chain(:find).and_return(Group)
      expect(Group).to receive(:lings).and_return @group.lings
      expect(Group).to receive(:memberships).and_return @group.memberships

      get :show, :id => @membership.id, :group_id => @group.id
      expect(assigns(:membership)).to eq @membership
    end
  end

  describe "new" do
    it "should authorize :create on @membership" do
      @group = groups(:inclusive)
      @membership = FactoryGirl.create(:membership, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:create, @membership).and_return(true)

      allow(Membership).to receive_message_chain(:new).and_return(@membership)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new membership to @membership" do
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:membership)).to be_new_record
      end

      it "all users to @users" do
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:users).size).to eq User.count
      end
    end
  end

  describe "edit" do

    it "should authorize :update on @membership" do
      @group = groups(:inclusive)
      @membership = FactoryGirl.create(:membership, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:update, @membership).and_return(true)

      allow(Membership).to receive_message_chain(:find).and_return @membership
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:memberships).and_return Membership
      get :edit, :id => @membership.id, :group_id => @group.id
    end

    it "loads the requested membership through current group" do
      @group = groups(:inclusive)
      @membership = FactoryGirl.create(:membership, :group => @group)
      allow(Group).to receive_message_chain(:find).and_return Group

      expect(Group).to receive(:memberships).and_return @group.memberships

      get :edit, :id => @membership.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested membership to @membership" do
        @group = groups(:inclusive)
        @membership = FactoryGirl.create(:membership, :group => @group)

        get :edit, :id => @membership.id, :group_id => @group.id

        expect(assigns(:membership)).to eq @membership
      end

      it "all users to @users" do
        @group = groups(:inclusive)
        @membership = FactoryGirl.create(:membership, :group => @group)

        get :edit, :id => @membership.id, :group_id => @group.id

        expect(assigns(:users).size).to eq User.count
      end
    end
  end

  describe "create" do

    it "should authorize :create on the membership" do
      @group = groups(:inclusive)
      @user = FactoryGirl.create(:user)
      @membership = FactoryGirl.create(:membership, :group => @group, :member => @user)

      expect(@ability).to receive(:can?).ordered.with(:create, @membership).and_return(true)

      allow(Membership).to receive_message_chain(:new).and_return(@membership)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :membership => {'level' => 'member', :member_id => @user.id}, :group_id => @group.id
    end

    describe "with valid params" do
      it "assigns a newly created membership to @membership" do
        expect {
          post :create, :membership => {'level' => 'member', :member_id => FactoryGirl.create(:user).id}, :group_id => groups(:inclusive).id
          expect(assigns(:membership)).not_to be_new_record
          expect(assigns(:membership)).to be_valid
          expect(assigns(:membership).level).to eq 'member'
          expect(assigns(:group)).to eq groups(:inclusive)
        }.to change(Membership, :count).by(1)
      end

      it "redirects to the created membership" do
        post :create, :membership => {'level' => 'member', :member_id => FactoryGirl.create(:user).id}, :group_id => groups(:inclusive).id
        expect(response).to redirect_to(group_membership_url(assigns(:group), assigns(:membership)))
      end

      it "should set creator to be the currently logged in user" do
        user = FactoryGirl.create(:user)
        group_admin = FactoryGirl.create(:user, :access_level => 'user', :name => 'admin', :email => 'a@dmin.com')
        Membership.create(:member => group_admin, :group => groups(:inclusive), :level => "admin")
        sign_in group_admin
        post :create, :membership => {'level' => 'member', :member_id => user.id}, :group_id => groups(:inclusive).id
        expect(assigns(:membership).creator).to eq group_admin
      end

      it "should set the group to current group" do
        user = FactoryGirl.create(:user)
        @group = groups(:inclusive)

        post :create, :membership => {'level' => 'member', :member_id => user.id}, :group_id => @group.id

        expect(assigns(:group)).to eq @group
        expect(assigns(:membership).group).to eq @group
      end
    end

     describe "with invalid params" do
      def do_invalid_create
        post :create, :membership => { 'level' => '', :member_id => FactoryGirl.create(:user).id }, :group_id => groups(:inclusive).id
      end

      it "does not save a new membership" do
        expect {
          do_invalid_create
          expect(assigns(:membership)).not_to be_valid
        }.to change(Membership, :count).by(0)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        expect(response).to be_success
        expect(response).to render_template("new")
      end
    end
  end

  describe "update" do

    it "should authorize :update on the passed membership" do
      @group = FactoryGirl.create(:group)
      @membership = FactoryGirl.create(:membership, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:update, @membership).and_return(true)

      allow(Membership).to receive_message_chain(:find).and_return(@membership)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id
    end

    it "loads the requested membership through current group" do
      @membership = FactoryGirl.create(:membership)
      @group = @membership.group
      @mems = @group.memberships
      allow(Group).to receive_message_chain(:find).and_return @group

      expect(@group).to receive(:memberships).and_return @mems

      put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id

      expect(assigns(:membership)).to eq @membership
    end

    describe "with valid params" do
      it "calls update on the requested membership" do
        @membership = FactoryGirl.create(:membership)
        @group = @membership.group
        allow(@group).to receive_message_chain(:memberships).and_return Membership
        allow(Membership).to receive_message_chain(:find).with(@membership.id.to_s).and_return @membership
        allow(Group).to receive_message_chain(:find).and_return @group
        
        expect(@membership).to receive(:update_attributes).with({:level => ''}).and_return true

        put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id
      end

      it "assigns the requested membership as @membership" do
        membership = FactoryGirl.create(:membership, :group => groups(:inclusive))
        put :update, :id => membership.id, :group_id => groups(:inclusive).id
        expect(assigns(:membership)).to eq membership
      end

      it "redirects to the membership" do
        @group = groups(:inclusive)
        membership = FactoryGirl.create(:membership, :group => @group)

        put :update, :id => membership, :group_id => @group.id

        expect(response).to redirect_to(group_membership_url(@group, membership))
      end
    end

    describe "with invalid params" do
      it "assigns the membership as @membership" do
        @membership = FactoryGirl.create(:membership, :group => groups(:inclusive))
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        expect(assigns(:membership)).to eq @membership
      end

      it "re-renders the 'edit' template" do
        @membership = FactoryGirl.create(:membership, :group => groups(:inclusive))
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        expect(response).to render_template("edit")
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_membership(membership)
      delete :destroy, :group_id => membership.group.id, :id => membership.id
    end

    it "should authorize :destroy on the passed membership" do
      @membership = FactoryGirl.create(:membership)
      @group = @membership.group

      expect(@ability).to receive(:can?).ordered.with(:destroy, @membership).and_return(true)

      allow(Group).to receive_message_chain(:find).and_return(@group)
      do_destroy_on_membership(@membership)
    end

    it "loads the membership through current group" do
      @membership = FactoryGirl.create(:membership)
      @group = @membership.group

      expect(@group).to receive(:memberships).and_return Membership.where(:group_id => @group)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @membership.id
    end

    it "calls destroy on the requested membership" do
      @membership = FactoryGirl.create(:membership)
      @group = @membership.group
      allow(@group).to receive_message_chain(:memberships).and_return Membership

      expect(@membership).to receive(:destroy).and_return(true)

      allow(Membership).to receive_message_chain(:find).and_return @membership
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_membership(@membership)
    end

    it "redirects to the memberships list" do
      @group = groups(:inclusive)
      @membership = FactoryGirl.create(:membership, :group => @group)

      delete :destroy, :id => @membership.id, :group_id => @group.id

      expect(response).to redirect_to(group_memberships_url(@group))
    end
  end
end
