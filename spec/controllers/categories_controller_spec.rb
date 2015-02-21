require 'spec_helper'

describe CategoriesController do
  before do
    allow_message_expectations_on_nil
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@categories should contain categories for the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)

      allow(Group).to receive_message_chain(:categories).and_return @group.categories

      get :index, :group_id => @group.id
    end
  end

  describe "show" do
    it "@category should be found by id through current_group" do
      @group = groups(:inclusive)
      @category = categories(:inclusive1)
      expect(@category.group) == @group
      allow(Group).to receive_message_chain(:find).and_return(Group)
      allow(Group).to receive_message_chain(:categories).and_return @group.categories

      get :show, :id => @category.id, :group_id => @group.id
      expect(assigns(:category)) == @category
    end
  end

  describe "new" do
    it "should authorize :create on @category" do
      @group = FactoryGirl.create(:group)
      @category = Category.new

      allow(@ability).to receive_message_chain(:can?).with(:create, @category).and_return(true)

      allow(Category).to receive_message_chain(:new).and_return(@category)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new category to @category" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:category).should be_new_record
      end
    end
  end

  describe "edit" do
    it "should authorize :update on @category" do
      @category = categories(:inclusive0)
      @group = @category.group

      allow(@ability).to receive_message_chain(:can?).with(:update, @category).and_return(true)

      allow(Category).to receive_message_chain(:find).and_return @category
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:categories).and_return @group.categories
      get :edit, :id => @category.id, :group_id => @group.id
    end

    it "loads the requested category through current group" do
      @category = categories(:inclusive0)
      @group = @category.group
      allow(Group).to receive_message_chain(:find).and_return Group

      allow(Group).to receive_message_chain(:categories).and_return @group.categories

      get :edit, :group_id => @group.id, :id => @category.id
    end

    describe "assigns" do
      it "the requested category's depth to @depth" do
        @category = categories(:inclusive1)
        get :edit, :id => @category.id, :group_id => groups(:inclusive).id
        expect(assigns(:depth)) == @category.depth
      end

      it "the requested category to @category" do
        @category = categories(:inclusive0)
        get :edit, :id => @category.id, :group_id => groups(:inclusive).id
        expect(assigns(:category)) == @category
      end
    end
  end

  describe "create" do
    it "should authorize :create on the passed category params" do
      @group = FactoryGirl.create(:group)
      @category = FactoryGirl.create(:category, :group => @group)

      allow(@ability).to receive_message_chain(:can?).with(:create, @category).and_return(true)

      allow(Category).to receive_message_chain(:new).and_return(@category)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :group_id => @group.id, :category => {'name' => 'Javanese', 'depth' => '0'}
    end

    describe "with valid params" do
      it "assigns a newly created category to @category" do
        lambda {
          post :create, :category => {'name' => 'FROMSPACE', :description => "lots of junk", :depth => '0'}, :group_id => groups(:inclusive).id
          assigns(:category).should_not be_new_record
          assigns(:category).should be_valid
          expect(assigns(:category).name) == 'FROMSPACE'
          expect(assigns(:category).description) == "lots of junk"
          expect(assigns(:category).depth) == 0
        }.should change(Category, :count).by(1)
      end

      it "redirects to the created category" do
        post :create, :category => {'name' => 'FROMSPACE', :depth => 0}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_category_url(assigns(:group), assigns(:category)))
      end

      it "should set creator to be the currently logged in user" do
        user = FactoryGirl.create(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        post :create, :category => {'name' => 'FROMSPACE', :depth => 0}, :group_id => groups(:inclusive).id
        expect(assigns(:category).creator) == user
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :category => {'name' => 'Javanese', 'depth' => '0'}

        expect(assigns(:group)) == @group
        expect(assigns(:category).group) == @group
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
    it "should authorize :update on the passed category" do
      @group = FactoryGirl.create(:group)
      @category = FactoryGirl.create(:category, :group => @group)

      allow(@ability).to receive_message_chain(:can?).with(:update, @category).and_return(true)

      allow(Category).to receive_message_chain(:find).and_return(@category)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      put :update, :id => @category.id, :category => {'name' => 'ayb', :depth => "0"}, :group_id => @group.id
    end

    it "loads the requested category through current group" do
      @category = categories(:inclusive0)
      @group = @category.group
      @cats = @group.categories
      allow(Group).to receive_message_chain(:find).and_return @group
      allow(@group).to receive_message_chain(:categories).and_return @cats

      put :update, :group_id => @group.id, :id => @category.id, :category => {'name' => 'eengleesh'}

      expect(assigns(:category)) == @category
    end

    it "assigns the requested category's depth to @depth" do
      @category = categories(:inclusive1)
      @group = groups(:inclusive)
      expect(@category.depth) == 1

      put :update, :group_id => @group.id, :id => @category.id, :category => {'name' => 'eengleesh'}

      expect(assigns(:depth)) == 1
    end

    describe "with valid params" do
      it "calls update with the passed params on the requested category" do
        @category = categories(:inclusive0)
        @group = @category.group
        @group.to receive_message_chain(:categories).and_return Category
        allow(Category).to receive_message_chain(:find).with(@category.id.to_s).and_return(@category)
        allow(Group).to receive_message_chain(:find).and_return @group

        @category.to receive_message_chain(:update_attributes).with({'name' => 'ayb'}).and_return(true)

        put :update, :id => @category.id, :category => {'name' => 'ayb'}, :group_id => @group.id
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
        expect(assigns(:category)) == categories(:inclusive0)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    def do_destroy_on_category(category)
      delete :destroy, :group_id => category.group.id, :id => category.id
    end

    it "should authorize :destroy on the passed category" do
      @group = groups(:inclusive)
      @category = categories(:inclusive0)

      allow(@ability).to receive_message_chain(:can?).with(:destroy, @category).and_return(true)

      allow(Group).to receive_message_chain(:find).and_return(@group)
      do_destroy_on_category(@category)
    end

    it "loads the category through current group" do
      @category = categories(:inclusive0)
      @group = @category.group

      allow(@group).to receive_message_chain(:categories).and_return Category.where(:group_id => @group.id)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @category.id
    end

    it "calls destroy on the requested category" do
      @category = categories(:inclusive0)
      @group = @category.group
      allow(@group).to receive_message_chain(:categories).and_return Category

      allow(@category).to receive_message_chain(:destroy).and_return(true)

      allow(Category).to receive_message_chain(:find).and_return @category
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_category(@category)
    end

    it "redirects to the categories list" do
      delete :destroy, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
      response.should redirect_to(group_categories_url(assigns(:group)))
    end
  end
end
