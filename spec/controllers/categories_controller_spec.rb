require 'spec_helper'

describe CategoriesController do
  describe "index" do
    describe "assigns" do
      it "@categories should contain every category" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:categories).should include categories(:inclusive0)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@category should match the passed id" do
        get :show, :id => categories(:inclusive1), :group_id => groups(:inclusive).id
        assigns(:category).should == categories(:inclusive1)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new category to @category" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:category).should be_new_record
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested category to @category" do
        get :edit, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
        assigns(:category).should == categories(:inclusive0)
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created category to @category" do
        lambda {
          post :create, :category => {'name' => 'FROMSPACE', :depth => '0'}, :group_id => groups(:inclusive).id

          assigns(:category).should_not be_new_record
          assigns(:category).should be_valid
          assigns(:category).name.should == 'FROMSPACE'
          assigns(:category).depth.should == 0
        }.should change(Category, :count).by(1)
      end

      it "redirects to the created category" do
        post :create, :category => {'name' => 'FROMSPACE', :depth => 0}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_category_url(assigns(:group), assigns(:category)))
      end
    end

    describe "with invalid params" do
      it "does not save a new category" do
        lambda {
          post :create, :category => {'name' => '', :depth => nil}, :group_id => groups(:inclusive).id
          assigns(:category).should_not be_valid
        }.should change(Category, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :category => {}, :group_id => groups(:inclusive).id
        response.should render_template("new")
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested category" do
        category = categories(:inclusive0)
        category.should_receive(:update_attributes).with({'name' => 'ayb'}).and_return(true)
        Category.should_receive(:find).with(category.id).and_return(category)

        put :update, :id => category.id, :category => {'name' => 'ayb'}, :group_id => groups(:inclusive).id
      end

      it "assigns the requested category as @category" do
        put :update, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
        assigns(:category).should == categories(:inclusive0)
      end

      it "redirects to the category" do
        put :update, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
        response.should redirect_to(group_category_url(assigns(:group), categories(:inclusive0)))
      end
    end

    describe "with invalid params" do
      before do
        put :update, :id => categories(:inclusive0), :category => {'name' => ''}, :group_id => groups(:inclusive).id
      end

      it "assigns the category as @category" do
        assigns(:category).should == categories(:inclusive0)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    it "calls destroy on the requested category" do
      category = categories(:inclusive0)
      category.should_receive(:destroy).and_return(true)
      Category.should_receive(:find).with(category.id).and_return(category)

      delete :destroy, :id => category.id, :group_id => groups(:inclusive).id
    end

    it "redirects to the categories list" do
      delete :destroy, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
      response.should redirect_to(group_categories_url(assigns(:group)))
    end
  end
end
