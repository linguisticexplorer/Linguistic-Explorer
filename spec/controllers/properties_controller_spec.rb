require 'spec_helper'

describe PropertiesController do
  describe "index" do
    describe "assigns" do
      it "@properties should contain every property" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:properties).should include properties(:valid)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@property should match the passed id" do
        get :show, :id => properties(:valid), :group_id => groups(:inclusive).id
        assigns(:property).should == properties(:valid)
      end
    end
  end

  describe "new" do
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
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested property to @property" do
        get :edit, :id => properties(:valid), :group_id => groups(:inclusive).id
        assigns(:property).should == properties(:valid)
      end

      it "@categories should be a hash with two level members" do
        get :edit, :id => properties(:valid), :group_id => groups(:inclusive).id
        cats = assigns(:categories)
        cats.should be_a Hash
        cats[:depth_0].should include categories(:inclusive0)
        cats[:depth_1].should include categories(:inclusive1)
      end
    end
  end

  describe "create" do
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
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      def do_valid_update_on_property(property)
        put :update, :id => property.id, :property => {'name' => 'ayb'}, :group_id => groups(:inclusive).id
      end

      it "calls update with the passed params on the requested property" do
        property = properties(:valid)
        property.should_receive(:update_attributes).with({'name' => 'ayb'}).and_return(true)
        Property.should_receive(:find).with(property.id).and_return(property)
        do_valid_update_on_property(property)
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
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    it "calls destroy on the requested property" do
      property = properties(:valid)
      property.should_receive(:destroy).and_return(true)
      Property.should_receive(:find).with(property.id).and_return(property)

      delete :destroy, :id => property.id, :group_id => groups(:inclusive).id
    end

    it "redirects to the properties list" do
      delete :destroy, :id => properties(:valid), :group_id => groups(:inclusive).id
      response.should redirect_to(group_properties_url(assigns(:group)))
    end
  end
end
