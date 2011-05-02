require 'spec_helper'

describe ExamplesLingsPropertiesController do
  describe "index" do
    describe "assigns" do
      it "@examples_lings_properties should contain every examples_lings_property" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:examples_lings_properties).should include examples_lings_properties(:inclusive)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@examples_lings_property should match the passed id" do
        get :show, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
        assigns(:examples_lings_property).should == examples_lings_properties(:inclusive)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      def do_new
        get :new, :group_id => groups(:inclusive).id
      end
      it "a new examples_lings_property to @examples_lings_property" do
        do_new
        assigns(:examples_lings_property).should be_new_record
      end

      it "available examples to @examples" do
        do_new
        assigns(:examples).size.should == Example.all.size
      end

      it "available lings_properties to @lings_properties" do
        do_new
        assigns(:lings_properties).size.should == LingsProperty.all.size
      end
    end
  end

  describe "edit" do
    def do_edit
      get :edit, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
    end

    describe "assigns" do
      it "the requested examples_lings_property to @examples_lings_property" do
        do_edit
        assigns(:examples_lings_property).should == examples_lings_properties(:inclusive)
      end

      it "available examples to @examples" do
        do_edit
        assigns(:examples).size.should == Example.all.size
      end

      it "available lings_properties to @lings_properties" do
        do_edit
        assigns(:lings_properties).size.should == LingsProperty.all.size
      end
    end
  end

  describe "create" do
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
        sign_in user
        example = examples(:inclusive)
        lings_property = lings_properties(:inclusive)
        post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id}, :group_id => groups(:inclusive).id
        assigns(:examples_lings_property).creator.should == user
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

      it "assigns available lings to @lings" do
        post :create, :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
        assigns(:examples).size.should == Example.all.size
      end

      it "available properties to @properties" do
        post :create, :examples_lings_property => {}, :group_id => groups(:inclusive).id
        assigns(:lings_properties).size.should == LingsProperty.all.size
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested property" do
        examples_lings_property = examples_lings_properties(:inclusive)
        example = Factory(:example, :ling => examples_lings_property.lings_property.ling, :group => groups(:inclusive))
        examples_lings_property.should_receive(:update_attributes).with("example_id" => example.id).and_return(true)
        ExamplesLingsProperty.should_receive(:find).with(examples_lings_property.id).and_return(examples_lings_property)

        put :update, :id => examples_lings_property.id, :examples_lings_property => {:example_id => example.id}, :group_id => groups(:inclusive).id
      end

      it "assigns the requested examples_lings_property as @examples_lings_property" do
        examples_lings_property = examples_lings_properties(:inclusive)
        example = Factory(:example, :ling => examples_lings_property.lings_property.ling, :group => groups(:inclusive))
        put :update, :id => examples_lings_property.id, :examples_lings_property => {:example_id => example.id}, :group_id => groups(:inclusive).id
        assigns(:examples_lings_property).should == examples_lings_properties(:inclusive)
      end

      it "redirects to the property" do
        examples_lings_property = examples_lings_properties(:inclusive)
        example = Factory(:example, :ling => examples_lings_property.lings_property.ling, :group => groups(:inclusive))
        put :update, :id => examples_lings_property.id, :examples_lings_property => {:example_id => example.id}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_examples_lings_property_path(assigns(:group), examples_lings_properties(:inclusive)))
      end
    end

    describe "with invalid params" do
      def do_invalid_update
        put :update, :id => examples_lings_properties(:inclusive), :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
      end

      describe "assigns" do
        it "the examples_lings_property as @examples_lings_property" do
          do_invalid_update
          assigns(:examples_lings_property).should == examples_lings_properties(:inclusive)
        end

        it "available lings to @lings" do
          do_invalid_update
          assigns(:examples).size.should == Example.all.size
        end

        it "available properties to @properties" do
          do_invalid_update
          assigns(:lings_properties).size.should == LingsProperty.all.size
        end
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    it "calls destroy on the requested examples_lings_property" do
      examples_lings_property = examples_lings_properties(:inclusive)
      examples_lings_property.should_receive(:destroy).and_return(true)
      ExamplesLingsProperty.should_receive(:find).with(examples_lings_property.id).and_return(examples_lings_property)
      delete :destroy, :id => examples_lings_property.id, :group_id => groups(:inclusive).id
    end

    it "redirects to the examples_lings_properties list" do
      delete :destroy, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
      response.should redirect_to(group_examples_lings_properties_url(assigns(:group)))
    end
  end
end
