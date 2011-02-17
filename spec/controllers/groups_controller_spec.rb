require 'spec_helper'

describe GroupsController do
  describe "index" do
    describe "assigns" do
      it "@groups should contain every group" do
        get :index
        assigns(:groups).should include groups(:inclusive)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@group should match the passed id" do
        get :show, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new group to @group" do
        get :new
        assigns(:group).should be_new_record
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested group to @group" do
        get :edit, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created group to @group" do
        lambda {
          post :create, :group => {'name' => 'TheBestTheBestTheBest'}
          assigns(:group).should_not be_new_record
          assigns(:group).should be_valid
          assigns(:group).name.should == 'TheBestTheBestTheBest'
        }.should change(Group, :count).by(1)
      end

      it "redirects to the created group" do
        post :create, :group => {'name' => 'NewGroup'}
        response.should redirect_to(group_url(assigns(:group)))
      end
    end

    describe "with invalid params" do
      it "does not save a new group" do
        lambda {
          post :create, :group => {'name' => ''}
          assigns(:group).should_not be_valid
        }.should change(Group, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :group => {}
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested group" do
        group = groups(:inclusive)
        group.should_receive(:update_attributes).with({'name' => 'number1group'}).and_return(true)
        Group.should_receive(:find).with(group.id).and_return(group)

        put :update, :id => group.id, :group => {'name' => 'number1group'}
      end

      it "assigns the requested group as @group" do
        put :update, :id => groups(:inclusive).id
        assigns(:group).should == groups(:inclusive)
      end

      it "redirects to the group" do
        put :update, :id => groups(:inclusive).id
        response.should redirect_to(group_url(groups(:inclusive)))
      end
    end

    describe "with invalid params" do
      before do
        put :update, :id => groups(:inclusive).id, :group => {'name' => ''}
      end

      it "assigns the group as @group" do
        assigns(:group).should == groups(:inclusive)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    it "calls destroy on the requested group" do
      group = groups(:inclusive)
      group.should_receive(:destroy).and_return(true)
      Group.should_receive(:find).with(group.id).and_return(group)

      delete :destroy, :id => group.id
    end

    it "redirects to the groups list" do
      delete :destroy, :id => groups(:inclusive).id
      response.should redirect_to(groups_url)
    end
  end
end
