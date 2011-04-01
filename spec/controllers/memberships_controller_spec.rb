require 'spec_helper'

describe MembershipsController do
  describe "index" do
    describe "assigns" do
      it "@memberships should contain every membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        get :index, :group_id => groups(:inclusive).id
        assigns(:memberships).should include membership
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@membership should match the passed id" do
        membership = Factory(:membership, :group => groups(:inclusive))
        get :show, :id => membership.id, :group_id => groups(:inclusive).id
        assigns(:membership).should == membership
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new membership to @membership" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:membership).should be_new_record
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested membership to @membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        get :edit, :id => membership.id, :group_id => groups(:inclusive).id
        assigns(:membership).should == membership
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created membership to @membership" do
        lambda {
          post :create, :membership => {'level' => 'member', :user_id => Factory(:user).id}, :group_id => groups(:inclusive).id
          assigns(:membership).should_not be_new_record
          assigns(:membership).should be_valid
          assigns(:membership).level.should == 'member'
          assigns(:group).should == groups(:inclusive)
        }.should change(Membership, :count).by(1)
      end

      it "redirects to the created membership" do
        post :create, :membership => {'level' => 'member', :user_id => Factory(:user).id}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_membership_url(assigns(:group), assigns(:membership)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        group_admin = Factory(:user, :access_level => 'user', :name => 'admin', :email => 'a@dmin.com')
        Membership.create(:user => group_admin, :group => groups(:inclusive), :level => "admin")
        sign_in group_admin
        post :create, :membership => {'level' => 'member', :user_id => user.id}, :group_id => groups(:inclusive).id
        assigns(:membership).creator.should == group_admin
      end
    end

     describe "with invalid params" do
      it "does not save a new membership" do
        lambda {
          post :create, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
          assigns(:membership).should_not be_valid
        }.should change(Membership, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        membership.should_receive(:update_attributes).with({'level' => ''}).and_return(true)
        Membership.should_receive(:find).with(membership.id).and_return(membership)

        put :update, :id => membership.id, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
      end

      it "assigns the requested membership as @membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => membership, :group_id => groups(:inclusive).id
        assigns(:membership).should == membership
      end

      it "redirects to the membership" do
        membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => membership, :group_id => groups(:inclusive).id
        response.should redirect_to(group_membership_url(assigns(:group), membership))
      end
    end

    describe "with invalid params" do
      before do
        @membership = Factory(:membership, :group => groups(:inclusive))
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
      end

      it "assigns the membership as @membership" do
        put :update, :id => @membership, :membership => {'level' => ''}, :group_id => groups(:inclusive).id
        assigns(:membership).should == @membership
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    it "calls destroy on the requested membership" do
      membership = Factory(:membership)
      membership.should_receive(:destroy).and_return(true)
      Membership.should_receive(:find).with(membership.id).and_return(membership)

      delete :destroy, :id => membership.id, :group_id => groups(:inclusive).id
    end

    it "redirects to the memberships list" do
      delete :destroy, :id => Factory(:membership).id, :group_id => groups(:inclusive).id
      response.should redirect_to(group_memberships_url(assigns(:group)))
    end
  end
end
