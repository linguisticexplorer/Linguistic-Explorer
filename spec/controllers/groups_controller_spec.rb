require 'spec_helper'

describe GroupsController do
  describe "index" do
    describe "assigns" do
      it "@groups should contain every group" do
        get :index
        assigns(:groups).should include groups(:inclusive)
      end
    end

    describe "with a valid group_id parameter" do
      it "should redirect to show for that group" do
        get :index, :group_id => groups(:inclusive).id
        response.should redirect_to(group_path(groups(:inclusive)))
        assigns[:group].should == groups(:inclusive)
      end
    end

    describe "with a group_id parameter that doesn't actually point to a group" do
      it "should render index as normal" do
        get :index, :group_id => "invalid-id"
        response.should_not redirect_to(groups_path + "/invalid-id")
        assigns[:group].should be_nil
      end
    end
  end

  describe "show" do
    it "should set session[:current_group] " do
      get :show, :id => groups(:inclusive).id
    end

    describe "assigns" do
      it "@group should match the requested group id" do
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

    describe "sets default field values:" do
      Group::DEFAULTS.each do |key,value|
        it "#{key} is #{value}" do
          get :new
          group = assigns(:group)
          group.send(key).should == value
        end
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
          post :create, :group => {:name => 'TheBestTheBestTheBest', :depth_maximum => "1"}
          assigns(:group).should_not be_new_record
          assigns(:group).should be_valid
          assigns(:group).name.should == 'TheBestTheBestTheBest'
        }.should change(Group, :count).by(1)
      end

      it "redirects to the created group" do
        @group = groups(:inclusive)
        params = {:name => 'NewGroup'}
        Group.should_receive(:new).and_return(@group)

        post :create, :group => params
        assigns[:group].should == @group
        response.should redirect_to(group_url(assigns[:group]))
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
      it "updates the requested group" do
        group = groups(:inclusive)
        group.name.should_not == 'number1group'
        put :update, :id => group.id, :group => {'name' => 'number1group'}
        group.reload
        group.name.should == 'number1group'
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
      group_id = groups(:inclusive).id
      Group.find(group_id).should_not be_nil
      delete :destroy, :id => group_id
      Group.find_by_id(group_id).should be_nil
    end

    it "redirects to the groups list" do
      delete :destroy, :id => groups(:inclusive).id
      response.should redirect_to(groups_url)
    end
  end
end
