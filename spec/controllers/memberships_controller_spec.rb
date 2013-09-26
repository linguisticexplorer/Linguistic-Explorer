require 'spec_helper'

describe MembershipsController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@memberships should load through the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)

      Group.should_receive(:memberships).and_return @group.memberships

      get :index, :group_id => @group.id
    end

    describe "assigns" do
      it "@memberships should contain memberships for the passed group" do
        @group = groups(:inclusive)
        membership = Factory(:membership, :group => @group)

        get :index, :group_id => @group.id, :letter => "all"

        assigns(:memberships).first.should include membership
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@membership should match the passed id" do
        @group = groups(:inclusive)
        membership = Factory(:membership, :group => @group)

        get :show, :id => membership.id, :group_id => @group.id

        assigns(:membership).should == membership
      end
    end

    it "@membership should be load through current_group" do
      @group = groups(:inclusive)
      @membership = Factory(:membership, :group => @group)

      Group.stub(:find).and_return(Group)
      Group.should_receive(:memberships).and_return @group.memberships

      get :show, :id => @membership.id, :group_id => @group.id
      assigns(:membership).should == @membership
    end
  end

  describe "new" do
    it "should authorize :create on @membership" do
      @group = groups(:inclusive)
      @membership = Factory(:membership, :group => @group)

      @ability.should_receive(:can?).ordered.with(:create, @membership).and_return(true)

      Membership.stub(:new).and_return(@membership)
      Group.stub(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new membership to @membership" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:membership).should be_new_record
      end

      it "all users to @users" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:users).size.should == User.count
      end
    end
  end

  describe "edit" do
    it "should authorize :update on @membership" do
      @group = groups(:inclusive)
      @membership = Factory(:membership, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @membership).and_return(true)

      Membership.stub(:find).and_return @membership
      Group.stub(:find).and_return Group
      Group.stub(:memberships).and_return Membership
      get :edit, :id => @membership.id, :group_id => @group.id
    end

    it "loads the requested membership through current group" do
      @group = groups(:inclusive)
      @membership = Factory(:membership, :group => @group)
      Group.stub(:find).and_return Group

      Group.should_receive(:memberships).and_return @group.memberships

      get :edit, :id => @membership.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested membership to @membership" do
        @group = groups(:inclusive)
        @membership = Factory(:membership, :group => @group)

        get :edit, :id => @membership.id, :group_id => @group.id

        assigns(:membership).should == @membership
      end

      it "all users to @users" do
        @group = groups(:inclusive)
        @membership = Factory(:membership, :group => @group)

        get :edit, :id => @membership.id, :group_id => @group.id

        assigns(:users).size.should == User.count
      end
    end
  end

  describe "create" do
    it "should authorize :create on the membership" do
      @group = groups(:inclusive)
      @user = Factory(:user)
      @membership = Factory(:membership, :group => @group, :member => @user)

      @ability.should_receive(:can?).ordered.with(:create, @membership).and_return(true)

      Membership.stub(:new).and_return(@membership)
      Group.stub(:find).and_return(@group)
      post :create, :membership => {'level' => 'member', :member_id => @user.id}, :group_id => @group.id
    end

    describe "with valid params" do
      it "assigns a newly created membership to @membership" do
        lambda {
          post :create, :membership => {'level' => 'member', :member_id => Factory(:user).id}, :group_id => groups(:inclusive).id
          assigns(:membership).should_not be_new_record
          assigns(:membership).should be_valid
          assigns(:membership).level.should == 'member'
          assigns(:group).should == groups(:inclusive)
        }.should change(Membership, :count).by(1)
      end

      it "redirects to the created membership" do
        post :create, :membership => {'level' => 'member', :member_id => Factory(:user).id}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_membership_url(assigns(:group), assigns(:membership)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        group_admin = Factory(:user, :access_level => 'user', :name => 'admin', :email => 'a@dmin.com')
        Membership.create(:member => group_admin, :group => groups(:inclusive), :level => "admin")
        sign_in group_admin
        post :create, :membership => {'level' => 'member', :member_id => user.id}, :group_id => groups(:inclusive).id
        assigns(:membership).creator.should == group_admin
      end

      it "should set the group to current group" do
        user = Factory(:user)
        @group = groups(:inclusive)

        post :create, :membership => {'level' => 'member', :member_id => user.id}, :group_id => @group.id

        assigns(:group).should == @group
        assigns(:membership).group.should == @group
      end
    end

     describe "with invalid params" do
      def do_invalid_create
        post :create, :membership => { 'level' => '', :member_id => Factory(:user).id }, :group_id => groups(:inclusive).id
      end

      it "does not save a new membership" do
        lambda {
          do_invalid_create
          assigns(:membership).should_not be_valid
        }.should change(Membership, :count).by(0)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed membership" do
      @group = Factory(:group)
      @membership = Factory(:membership, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @membership).and_return(true)

      Membership.stub(:find).and_return(@membership)
      Group.stub(:find).and_return(@group)
      put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id
    end

    it "loads the requested membership through current group" do
      @membership = Factory(:membership)
      @group = @membership.group
      @mems = @group.memberships
      Group.stub(:find).and_return @group

      @group.should_receive(:memberships).and_return @mems

      put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id

      assigns(:membership).should == @membership
    end

    describe "with valid params" do
      it "calls update on the requested membership" do
        @membership = Factory(:membership)
        @group = @membership.group
        @group.stub(:memberships).and_return Membership
        Membership.stub(:find).with(@membership.id).and_return @membership
        Group.stub(:find).and_return @group

        @membership.should_receive(:update_attributes).with({'level' => ''}).and_return true

        put :update, :id => @membership.id, :membership => {'level' => ''}, :group_id => @group.id
      end

      it "assigns the requested membership as @membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => membership, :group_id => groups(:inclusive).id
        assigns(:membership).should == membership
      end

      it "redirects to the membership" do
        @group = groups(:inclusive)
        membership = Factory(:membership, :group => @group)

        put :update, :id => membership, :group_id => @group.id

        response.should redirect_to(group_membership_url(@group, membership))
      end
    end

    describe "with invalid params" do
      it "assigns the membership as @membership" do
        @membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        assigns(:membership).should == @membership
      end

      it "re-renders the 'edit' template" do
        @membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_membership(membership)
      delete :destroy, :group_id => membership.group.id, :id => membership.id
    end

    it "should authorize :destroy on the passed membership" do
      @membership = Factory(:membership)
      @group = @membership.group

      @ability.should_receive(:can?).ordered.with(:destroy, @membership).and_return(true)

      Group.stub(:find).and_return(@group)
      do_destroy_on_membership(@membership)
    end

    it "loads the membership through current group" do
      @membership = Factory(:membership)
      @group = @membership.group

      @group.should_receive(:memberships).and_return Membership.where(:group => @group)

      Group.stub(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @membership.id
    end

    it "calls destroy on the requested membership" do
      @membership = Factory(:membership)
      @group = @membership.group
      @group.stub(:memberships).and_return Membership

      @membership.should_receive(:destroy).and_return(true)

      Membership.stub(:find).and_return @membership
      Group.stub(:find).and_return @group
      do_destroy_on_membership(@membership)
    end

    it "redirects to the memberships list" do
      @group = groups(:inclusive)
      @membership = Factory(:membership, :group => @group)

      delete :destroy, :id => @membership.id, :group_id => @group.id

      response.should redirect_to(group_memberships_url(@group))
    end
  end
end
