require 'spec_helper'

describe ExamplesLingsPropertiesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@examples_lings_properties should contain examples_lings_properties from the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)

      Group.should_receive(:examples_lings_properties).and_return @group.examples_lings_properties

      get :index, :group_id => @group.id
    end
  end

  describe "show" do
    describe "assigns" do
      it "@examples_lings_property should match the passed id" do
        get :show, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
        assigns(:examples_lings_property).should == examples_lings_properties(:inclusive)
      end
    end

    it "@examples_lings_property should be found by id through current_group" do
      @elp = examples_lings_properties(:inclusive)
      @group = @elp.group
      Group.stub(:find).and_return(Group)

      Group.should_receive(:examples_lings_properties).and_return @group.examples_lings_properties

      get :show, :id => @elp.id, :group_id => @group.id
    end
  end

  describe "new" do
    it "should authorize :create on @examples_lings_property" do
      @group = Factory(:group)
      @elp = Example.new

      @ability.should_receive(:can?).ordered.with(:create, @elp).and_return(true)

      ExamplesLingsProperty.stub(:new).and_return(@elp)
      Group.stub(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new examples_lings_property to @examples_lings_property" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:examples_lings_property).should be_new_record
      end

      it "examples in current group to @examples" do
        @group = groups(:inclusive)
        get :new, :group_id => groups(:inclusive).id
        assigns(:examples).should == @group.examples
      end

      it "lings_properties in the current group to @lings_properties" do
        @group = groups(:inclusive)
        get :new, :group_id => groups(:inclusive).id
        assigns(:lings_properties).should == @group.lings_properties
      end
    end
  end

  describe "create" do
    it "should authorize :create on the examples_lings_property with params" do
      @group = groups(:inclusive)
      @lp = lings_properties(:level0)
      @example = Factory(:example, :ling => @lp.ling, :group => @group)

      @elp = ExamplesLingsProperty.new do |elp|
        elp.group = @group
        elp.example = @example
        elp.lings_property = @lp
      end

      @ability.should_receive(:can?).ordered.with(:create, @elp).and_return(true)

      ExamplesLingsProperty.stub(:new).and_return(@elp)
      Group.stub(:find).and_return(@group)
      post :create, :examples_lings_property => {'example_id' => @example.id, 'lings_property_id' => @lp.id}, :group_id => @group.id
    end

    describe "with valid params" do
      it "assigns a newly created examples_lings_property to @examples_lings_property" do
        lambda {
          example = examples(:inclusive)
          lings_property = lings_properties(:inclusive)

          post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id.to_i}, :group_id => groups(:inclusive).id

          assigns(:examples_lings_property).should_not be_new_record
          assigns(:examples_lings_property).should be_valid
          assigns(:examples_lings_property).example.should == example
          assigns(:examples_lings_property).lings_property.should == lings_property
        }.should change(ExamplesLingsProperty, :count).by(1)
      end

      it "redirects to the created examples_lings_property" do
        example = examples(:inclusive)
        lings_property = lings_properties(:inclusive)

        post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id}, :group_id => groups(:inclusive).id

        response.should redirect_to(group_examples_lings_property_url(assigns(:group), assigns(:examples_lings_property)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        example = examples(:inclusive)
        lings_property = lings_properties(:inclusive)

        sign_in user
        post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id}, :group_id => groups(:inclusive).id

        assigns(:examples_lings_property).creator.should == user
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)
        @lp = lings_properties(:level0)
        @example = Factory(:example, :ling => @lp.ling, :group => @group)

        post :create, :examples_lings_property => {'example_id' => @example.id, 'lings_property_id' => @lp.id}, :group_id => @group.id

        assigns(:group).should == @group
        assigns(:examples_lings_property).group.should == @group
      end
    end

    describe "with invalid params" do
      it "does not save a new property" do
        lambda {
          post :create, :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
          assigns(:examples_lings_property).should_not be_valid
        }.should change(ExamplesLingsProperty, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
        response.should be_success
        response.should render_template("new")
      end

      it "assigns examples from the group to @examples" do
        @example = examples(:inclusive)
        @group = @example.group
        @other_example = examples(:exclusive)

        post :create, :examples_lings_property => {:example_id => nil}, :group_id => @group.id

        assigns(:examples).should include @example
        assigns(:examples).should_not include @other_example
      end

      it "lings_properties from the current group into @lings_properties" do
        @lings_property = lings_properties(:level0)
        @group = @lings_property.group
        @other_lings_property = lings_properties(:exclusive)

        post :create, :examples_lings_property => {:example_id => nil}, :group_id => @group.id

        assigns(:lings_properties).should include @lings_property
        assigns(:lings_properties).should_not include @other_lings_property
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_examples_lings_property(elp)
      delete :destroy, :group_id => elp.group.id, :id => elp.id
    end

    before do
      @elp = examples_lings_properties(:inclusive)
      @group = @elp.group
    end

    it "should authorize :destroy on the passed examples_lings_property" do
      @ability.should_receive(:can?).ordered.with(:destroy, @elp).and_return(true)
      Group.stub(:find).and_return(@group)

      do_destroy_on_examples_lings_property(@elp)
    end

    it "loads the examples_lings_property through current group" do
      @group.should_receive(:examples_lings_properties).and_return ExamplesLingsProperty.where(:group => @group)
      Group.stub(:find).and_return @group

      do_destroy_on_examples_lings_property(@elp)
    end

    it "calls destroy on the requested examples_lings_property" do
      @group.stub(:examples_lings_properties).and_return ExamplesLingsProperty

      @elp.should_receive(:destroy).and_return(true)

      ExamplesLingsProperty.stub(:find).and_return @elp
      Group.stub(:find).and_return @group
      do_destroy_on_examples_lings_property(@elp)
    end

    it "redirects to the examples_lings_properties list" do
      delete :destroy, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
      response.should redirect_to(group_examples_lings_properties_url(assigns(:group)))
    end
  end
end
