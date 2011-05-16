require 'spec_helper'

describe PropertiesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@properties should load through the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)

      Group.should_receive(:properties).and_return @group.properties

      get :index, :group_id => @group.id
    end

    describe "assigns" do
      it "@properties should contain properties for the group" do
        get :index, :group_id => groups(:inclusive).id

        assigns(:properties).should include properties(:level0)
        assigns(:properties).should_not include properties(:exclusive0)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@property should match the passed id" do
        @property = properties(:valid)
        get :show, :id => @property.id, :group_id => @property.group.id
        assigns(:property).should == @property
      end

      it "@values should contain all values associated with the property" do
        @ling = lings(:level0)
        @group = @ling.group
        @lp = lings_properties(:level0)
        @lp.ling.should == @ling
        @property = @lp.property

        get :show, :id => @property.id, :group_id => @group.id

        assigns(:values).should include @lp
        assigns(:values).size.should == @property.lings_properties.size
      end
    end

    it "@property should be found by id through current_group" do
      @property = properties(:level0)
      @group = @property.group
      Group.stub(:find).and_return(Group)

      Group.should_receive(:properties).and_return @group.properties

      get :show, :id => @property.id, :group_id => @group.id
      assigns(:property).should == @property
    end
  end

  describe "new" do
    it "should authorize :create on @property" do
      @group = Factory(:group)
      @property = Property.new

      @ability.should_receive(:can?).ordered.with(:create, @property).and_return(true)

      Property.stub(:new).and_return(@property)
      Group.stub(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new property to @property" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:property).should be_new_record
      end

      it "@categories should be a hash with two level members" do
        get :new, :group_id => groups(:inclusive).id
        cats = assigns(:categories)

        cats.should be_a Hash
        cats[:depth_0].should include categories(:inclusive0)
        cats[:depth_1].should include categories(:inclusive1)
        cats[:depth_0].should_not include categories(:exclusive0)
        cats[:depth_1].should_not include categories(:exclusive1)
      end
    end
  end

  describe "edit" do
    it "should authorize :update on @property" do
      @property = properties(:level0)
      @group = @property.group

      @ability.should_receive(:can?).ordered.with(:update, @property).and_return(true)

      Property.stub(:find).and_return @property
      Group.stub(:find).and_return Group
      Group.stub(:properties).and_return @group.properties
      Group.stub(:categories).and_return @group.categories
      get :edit, :id => @property.id, :group_id => @group.id
    end

    it "loads the requested property through current group" do
      @property = properties(:level0)
      @group = @property.group
      Group.stub(:find).and_return Group
      Group.stub(:categories).and_return @group.categories

      Group.should_receive(:properties).and_return @group.properties

      get :edit, :id => @property.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested property to @property" do
        @property = properties(:valid)
        get :edit, :id => @property.id, :group_id => @property.group.id
        assigns(:property).should == @property
      end

      it "@categories should be a hash with two level members" do
        get :edit, :id => properties(:valid), :group_id => groups(:inclusive).id
        cats = assigns(:categories)

        cats.should be_a Hash
        cats[:depth_0].should include categories(:inclusive0)
        cats[:depth_1].should include categories(:inclusive1)
        cats[:depth_0].should_not include categories(:exclusive0)
        cats[:depth_1].should_not include categories(:exclusive1)
      end
    end
  end

  describe "create" do
    it "should authorize :create on the property with params" do
      @property = properties(:level0)
      @group = @property.group
      @category = Factory(:category, :group => @group)

      @ability.should_receive(:can?).ordered.with(:create, @property).and_return(true)

      Property.stub(:new).and_return(@property)
      Group.stub(:find).and_return(@group)
      post :create, :group_id => @group.id, :property => {'name' => 'Javanese', 'category_id' => @category.id}
    end

    describe "with valid params" do
      def do_valid_create
        post :create, :property => {'name' => 'FROMSPACE', :description => "lots of junk", :category_id => categories(:inclusive0).id}, :group_id => groups(:inclusive).id
      end

      it "assigns a newly created property to @property" do
        lambda {
          do_valid_create
          assigns(:property).should_not be_new_record
          assigns(:property).should be_valid
          assigns(:property).name.should == 'FROMSPACE'
          assigns(:property).description.should == "lots of junk"
          assigns(:property).category.should == categories(:inclusive0)
        }.should change(Property, :count).by(1)
      end

      it "redirects to the created property" do
        do_valid_create
        response.should redirect_to(group_property_url(assigns(:group), assigns(:property)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        do_valid_create
        assigns(:property).creator.should == user
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)
        @category = Factory(:category, :group => @group)

        post :create, :property => {'name' => 'FROMSPACE', :description => "lots of junk", :category_id => @category.id}, :group_id => @group.id

        assigns(:group).should == @group
        assigns(:property).group.should == @group
      end
    end

    describe "with invalid params" do
      def do_invalid_create
        post :create, :property => {'name' => ''}, :group_id => groups(:inclusive).id
      end

      it "does not save a new property" do
        lambda {
          do_invalid_create
          assigns(:property).should_not be_valid
        }.should change(Property, :count).by(0)
      end

      it "@categories should be a hash with two level members" do
        do_invalid_create
        cats = assigns(:categories)
        cats.should be_a Hash
        cats[:depth_0].should include categories(:inclusive0)
        cats[:depth_1].should include categories(:inclusive1)
        cats[:depth_0].should_not include categories(:exclusive0)
        cats[:depth_1].should_not include categories(:exclusive1)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed property" do
      @property = properties(:level0)
      @group = @property.group

      @ability.should_receive(:can?).ordered.with(:update, @property).and_return(true)

      Property.stub(:find).and_return(@property)
      Group.stub(:find).and_return(@group)
      put :update, :id => @property.id, :property => {'name' => 'ayb'}, :group_id => @group.id
    end

    it "loads the requested property through current group" do
      @property = properties(:level0)
      @group = @property.group
      @props = @group.properties
      Group.stub(:find).and_return @group
      @group.should_receive(:properties).and_return @props

      put :update, :group_id => @group.id, :id => @property.id, :property => {'name' => 'eengleesh'}

      assigns(:property).should == @property
    end

    describe "with valid params" do
      def do_valid_update_on_property(property)
        put :update, :id => property.id, :property => {'name' => 'ayb'}, :group_id => groups(:inclusive).id
      end

      it "calls update with the passed params on the requested property" do
        @property = properties(:level0)
        new_name = "foobard"
        @group = @property.group
        @group.stub(:properties).and_return Property
        Property.stub(:find).with(@property.id).and_return @property
        Group.stub(:find).and_return @group

        @property.should_receive(:update_attributes).with({'name' => new_name}).and_return true

        put :update, :id => @property.id, :property => {'name' => new_name}, :stored_values => {:text => "foo"}, :group_id => @group.id
      end

      it "assigns the requested property as @property" do
        do_valid_update_on_property(properties(:valid))
        assigns(:property).should == properties(:valid)
      end

      it "redirects to the property" do
        do_valid_update_on_property(properties(:valid))
        response.should redirect_to(group_property_url(assigns(:group), properties(:valid)))
      end
    end

    describe "with invalid params" do
      def do_invalid_update
        put :update, :id => properties(:valid), :property => {'name' => ''}, :group_id => groups(:inclusive).id
      end

      it "assigns the property as @property" do
        do_invalid_update
        assigns(:property).should == properties(:valid)
      end

      it "@categories should be a hash with two level members" do
        do_invalid_update
        cats = assigns(:categories)

        cats.should be_a Hash
        cats[:depth_0].should include categories(:inclusive0)
        cats[:depth_1].should include categories(:inclusive1)
        cats[:depth_0].should_not include categories(:exclusive0)
        cats[:depth_1].should_not include categories(:exclusive1)
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_property(property)
      delete :destroy, :group_id => property.group.id, :id => property.id
    end

    it "should authorize :destroy on the passed property" do
      @property = properties(:level0)
      @group = @property.group

      @ability.should_receive(:can?).ordered.with(:destroy, @property).and_return true

      Group.stub(:find).and_return @group
      do_destroy_on_property(@property)
    end

    it "loads the property through current group" do
      @property = properties(:level0)
      @group = @property.group

      @group.should_receive(:properties).and_return Property.where(:group => @group)

      Group.stub(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @property.id
    end

    it "calls destroy on the requested property" do
      @property = properties(:level0)
      @group = @property.group
      @group.stub(:properties).and_return Property

      @property.should_receive(:destroy).and_return(true)

      Property.stub(:find).and_return @property
      Group.stub(:find).and_return @group
      do_destroy_on_property(@property)
    end

    it "redirects to the properties list" do
      @property = properties(:level0)
      delete :destroy, :id => @property.id, :group_id => @property.group.id
      response.should redirect_to(group_properties_url(@property.group))
    end
  end
end
