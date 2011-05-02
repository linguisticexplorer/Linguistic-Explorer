require 'spec_helper'

describe ExamplesController do
  describe "index" do
    describe "assigns" do
      it "@examples should contain every example" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:examples).should include examples(:onceuponatime)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@example should match the passed id" do
        get :show, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        assigns(:example).should == examples(:onceuponatime)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new example to @example" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:example).should be_new_record
      end

      it "@lings should be a hash with two depth members" do
        get :new, :group_id => groups(:inclusive).id
        lings = assigns(:lings)
        lings.should be_a Hash
        lings[:depth_0].should include lings(:level0)
        lings[:depth_1].should include lings(:level1)
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested example to @example" do
        get :edit, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        assigns(:example).should == examples(:onceuponatime)
      end

      it "@lings should be a hash with two depth members" do
        get :edit, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        lings = assigns(:lings)
        lings.should be_a Hash
        lings[:depth_0].should include lings(:level0)
        lings[:depth_1].should include lings(:level1)
      end
    end
  end

  describe "create" do
    describe "with valid params on example as well as stored_values" do
      it "assigns a newly created example to @example" do
        lambda {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:text => "foo"}, :group_id => groups(:inclusive).id
          assigns(:example).should_not be_new_record
          assigns(:example).should be_valid
          assigns(:example).name.should == 'Javanese'
        }.should change(Example, :count).by(1)
      end

      it "creates and associates passed stored values" do
        lambda {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:text => "foo"}, :group_id => groups(:inclusive).id
          assigns(:example).stored_value(:text).should == 'foo'
        }.should change(StoredValue, :count).by(1)
      end

      it "redirects to the created example" do
        post :create, :example => {'name' => 'Javanese'}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_example_url(assigns(:group), assigns(:example)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        post :create, :example => {'name' => 'Javanese'}, :group_id => groups(:inclusive).id
        assigns(:example).creator.should == user
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested example" do
        example = examples(:onceuponatime)
        example.should_receive(:update_attributes).with({'name' => 'eengleesh'}).and_return(true)
        Example.should_receive(:find).with(example.id).and_return(example)

        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :stored_values => {:text => "foo"}, :group_id => groups(:inclusive).id
      end

      it "creates or updates passed stored values" do
        example = examples(:onceuponatime)
        #test creation of a new value of key 'text'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:text => "foo"}
        example.reload.stored_value(:text).should == 'foo'
        #now update 'text' value to be 'bar'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:text => "bar"}
        example.reload.stored_value(:text).should == 'bar'
      end

      it "assigns the requested example as @example" do
        put :update, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        assigns(:example).should == examples(:onceuponatime)
      end

      it "redirects to the example" do
        put :update, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        response.should redirect_to(group_example_url(assigns(:group), examples(:onceuponatime)))
      end
    end
  end

  describe "destroy" do
    it "calls destroy on the requested example" do
      example = examples(:onceuponatime)
      example.should_receive(:destroy).and_return(true)
      Example.should_receive(:find).with(example.id).and_return(example)

      delete :destroy, :id => example.id, :group_id => groups(:inclusive).id
    end

    it "redirects to the examples list" do
      delete :destroy, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
      response.should redirect_to(group_examples_url(assigns(:group)))
    end
  end
end
