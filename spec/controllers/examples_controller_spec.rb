require 'spec_helper'

describe ExamplesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@examples should load through the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)

      Group.should_receive(:examples).and_return @group.examples

      get :index, :group_id => @group.id
    end

    describe "assigns" do
      it "@examples should contain examples from the group" do
        get :index, :group_id => groups(:inclusive).id

        assigns(:examples).should include examples(:inclusive)
        assigns(:examples).should_not include examples(:exclusive)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@examples should match the passed id" do
        @example = examples(:onceuponatime)
        get :show, :id => @example.id, :group_id => @example.group.id
        assigns(:example).should == @example
      end
    end

    it "@example should be found by id through current_group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      Group.stub(:find).and_return(Group)

      Group.should_receive(:examples).and_return @group.examples

      get :show, :id => @example.id, :group_id => @group.id
      assigns(:example).should == @example
    end
  end

  describe "new" do
    it "should authorize :create on @example" do
      @group = Factory(:group)
      @example = Example.new

      @ability.should_receive(:can?).ordered.with(:create, @example).and_return(true)

      Example.stub(:new).and_return(@example)
      Group.stub(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new example to @example" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:example).should be_new_record
      end

    end
  end

  describe "edit" do
    it "should authorize :update on @example" do
      @example = examples(:onceuponatime)
      @group = @example.group

      @ability.should_receive(:can?).ordered.with(:update, @example).and_return(true)

      Example.stub(:find).and_return @example
      Group.stub(:find).and_return Group
      Group.stub(:examples).and_return @group.examples
      Group.stub(:lings).and_return @group.lings
      get :edit, :id => @example.id, :group_id => @group.id
    end

    it "loads the requested example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      Group.stub(:find).and_return Group
      Group.stub(:lings).and_return @group.lings

      Group.should_receive(:examples).and_return @group.examples

      get :edit, :id => @example.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested example to @example" do
        @example = examples(:onceuponatime)
        get :edit, :id => @example.id, :group_id => @example.group.id
        assigns(:example).should == @example
      end

      it "@lings should be a hash with two depth members" do
        get :edit, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        lings = assigns(:lings)
        lings.should be_a Hash
        lings[:depth_0].should include lings(:level0)
        lings[:depth_1].should include lings(:level1)
        lings[:depth_0].should_not include lings(:exclusive0)
        lings[:depth_1].should_not include lings(:exclusive1)
      end
    end
  end

  describe "create" do
    it "should authorize :create on the example with params" do
      @group = Factory(:group)
      @example = Factory(:example, :group => @group)

      @ability.should_receive(:can?).ordered.with(:create, @example).and_return(true)

      Example.stub(:new).and_return(@example)
      Group.stub(:find).and_return(@group)
      post :create, :group_id => @group.id, :example => {'name' => 'Javanese'} 
    end

    describe "with valid params and valid stored_values" do
      it "assigns a newly created example to @example" do
        lambda {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:description => "foo"}, :group_id => groups(:inclusive).id
          assigns(:example).should_not be_new_record
          assigns(:example).should be_valid
          assigns(:example).name.should == 'Javanese'
        }.should change(Example, :count).by(1)
      end

      it "creates and associates passed stored values" do
        lambda {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:description => "foo"}, :group_id => groups(:inclusive).id
          assigns(:example).stored_value(:description).should == 'foo'
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

      it "should set the group to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :example => {'name' => 'Javanese'}

        assigns(:group).should == @group
        assigns(:example).group.should == @group
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed example" do
      @group = Factory(:group)
      @example = Factory(:example, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @example).and_return(true)

      Example.stub(:find).and_return(@example)
      Group.stub(:find).and_return(@group)
      put :update, :id => @example.id, :example => {'name' => 'ayb'}, :group_id => @group.id
    end

    it "loads the requested example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      @exes = @group.examples
      Group.stub(:find).and_return @group
      @group.should_receive(:examples).and_return @exes

      put :update, :group_id => @group.id, :id => @example.id, :example => {'name' => 'eengleesh'}

      assigns(:example).should == @example
    end

    describe "with valid params" do
      it "calls update with the passed params on the requested example" do
        @example = examples(:onceuponatime)
        new_name = "foobard"
        @group = @example.group
        @group.stub(:examples).and_return Example
        Example.stub(:find).with(@example.id).and_return(@example)
        Group.stub(:find).and_return @group

        @example.should_receive(:update_attributes).with({'name' => new_name}).and_return(true)

        put :update, :id => @example.id, :example => {'name' => new_name}, :stored_values => {:description => "foo"}, :group_id => @example.group.id
      end

      it "creates or updates passed stored values" do
        example = examples(:onceuponatime)
        #test creation of a new value of key 'description'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:description => "foo"}
        example.reload.stored_value(:description).should == 'foo'
        #now update 'description' value to be 'bar'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:description => "bar"}
        example.reload.stored_value(:description).should == 'bar'
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
    def do_destroy_on_example(example)
      delete :destroy, :group_id => example.group.id, :id => example.id
    end

    it "should authorize :destroy on the passed example" do
      @example = examples(:onceuponatime)
      @group = @example.group

      @ability.should_receive(:can?).ordered.with(:destroy, @example).and_return(true)

      Group.stub(:find).and_return(@group)
      do_destroy_on_example(@example)
    end

    it "loads the example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group

      @group.should_receive(:examples).and_return Example.where(:group => @group)

      Group.stub(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @example.id
    end

    it "calls destroy on the requested example" do
      @example = examples(:onceuponatime)
      @group = @example.group
      @group.stub(:examples).and_return Example

      @example.should_receive(:destroy).and_return(true)

      Example.stub(:find).and_return @example
      Group.stub(:find).and_return @group
      do_destroy_on_example(@example)
    end

    it "redirects to the examples list" do
      delete :destroy, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
      response.should redirect_to(group_examples_url(assigns(:group)))
    end
  end
end
