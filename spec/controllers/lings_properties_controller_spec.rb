require 'spec_helper'

describe LingsPropertiesController do
  fixtures :all

  describe "index" do
    describe "assigns" do
      it "@lings_properties should contain every lings_property" do
        get :index
        assigns(:lings_properties).should include lings_properties(:smelly)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@lings_property should match the passed id" do
        get :show, :id => lings_properties(:smelly)
        assigns(:lings_property).should == lings_properties(:smelly)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new lings_property to @lings_property" do
        get :new
        assigns(:lings_property).should be_new_record
      end

      it "available lings to @lings" do
        get :new
        assigns(:lings).should_not be_nil
      end

      it "available properties to @properties" do
        get :new
        assigns(:properties).should_not be_nil
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested lings_property to @lings_property" do
        get :edit, :id => lings_properties(:smelly)
        assigns(:lings_property).should == lings_properties(:smelly)
      end

      it "available lings to @lings" do
        get :new
        assigns(:lings).should_not be_nil
      end

      it "available properties to @properties" do
        get :new
        assigns(:properties).should_not be_nil
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created lings_property to @lings_property" do
        lambda {
          ling = Ling.first
          property = Property.first
          post :create, :lings_property => {'value' => 'FROMSPACE', 'ling_id' => ling.id.to_i, 'property_id' => property.id.to_i}
          assigns(:lings_property).should_not be_new_record
          assigns(:lings_property).should be_valid
          assigns(:lings_property).value.should == 'FROMSPACE'
          assigns(:lings_property).ling.should == ling
          assigns(:lings_property).property.should == property
        }.should change(LingsProperty, :count).by(1)
      end

      it "redirects to the created property" do
        ling = Ling.first
        property = Property.first
        post :create, :lings_property => {'value' => 'FROMSPACE', 'ling_id' => ling.id, 'property_id' => property.id}
        response.should redirect_to(lings_property_url(assigns(:lings_property)))
      end
    end

    describe "with invalid params" do
      it "does not save a new property" do
        lambda {
          post :create, :lings_property => {'value' => ''}
          assigns(:lings_property).should_not be_valid
        }.should change(LingsProperty, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :lings_property => {}
        response.should be_success
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested property" do
        lings_property = lings_properties(:smelly)
        lings_property.should_receive(:update_attributes).with({'value' => 'no'}).and_return(true)
        LingsProperty.should_receive(:find).with(lings_property.id).and_return(lings_property)

        put :update, :id => lings_property.id, :lings_property => {'value' => 'no'}
      end

      it "assigns the requested lings_property as @lings_property" do
        put :update, :id => lings_properties(:smelly)
        assigns(:lings_property).should == lings_properties(:smelly)
      end

      it "redirects to the property" do
        put :update, :id => lings_properties(:smelly)
        response.should redirect_to(lings_property_url(lings_properties(:smelly)))
      end
    end

    describe "with invalid params" do
      before do
        put :update, :id => lings_properties(:smelly), :lings_property => {'value' => ''}
      end

      it "assigns the lings_property as @lings_property" do
        assigns(:lings_property).should == lings_properties(:smelly)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    it "calls destroy on the requested lings_property" do
      lings_property = lings_properties(:smelly)
      lings_property.should_receive(:destroy).and_return(true)
      LingsProperty.should_receive(:find).with(lings_property.id).and_return(lings_property)

      delete :destroy, :id => lings_property.id
    end

    it "redirects to the lings_properties list" do
      delete :destroy, :id => lings_properties(:smelly)
      response.should redirect_to(lings_properties_url)
    end
  end
end
