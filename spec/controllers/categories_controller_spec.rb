require 'spec_helper'

describe CategoriesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "index" do
    describe "assigns" do
      it "@categories should contain categories for the current group" do
        @group = groups(:inclusive)
        Group.stub(:find).and_return(Group)
        Group.should_receive(:categories).and_return @group.categories
        get :index, :group_id => @group.id
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@category should be found by id through current_group" do
        @group = groups(:inclusive)
        @category = categories(:inclusive1)
        @category.group.should == @group
        Group.stub(:find).and_return(Group)
        Group.should_receive(:categories).and_return @group.categories

        get :show, :id => @category.id, :group_id => @group.id
        assigns(:category).should == @category
      end
    end
  end

  describe "new" do
    it "should authorize :create on @category" do
      @group = Factory(:group)
      @category = Category.new

      @ability.should_receive(:can?).ordered.with(:create, @category).and_return(true)

      Category.stub(:new).and_return(@category)
      Group.stub(:find).and_return(@group)
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

      @ability.should_receive(:can?).ordered.with(:update, @category).and_return(true)

      Category.stub(:find).and_return @category
      Group.stub(:find).and_return Group
      Group.stub(:categories).and_return @group.categories
      get :edit, :id => @category.id, :group_id => @group.id
    end

    describe "assigns" do
      it "loads the requested category through current group" do
        @category = categories(:inclusive0)
        @group = @category.group

        Group.stub(:find).and_return Group
        Group.should_receive(:categories).and_return @group.categories
        get :edit, :group_id => @group.id, :id => @category.id

        assigns(:category).should == @category
      end

      it "the requested category's depth to @depth" do
        @category = categories(:inclusive1)
        get :edit, :id => @category.id, :group_id => groups(:inclusive).id
        assigns(:depth).should == @category.depth
      end

      it "the requested category to @category" do
        @category = categories(:inclusive0)
        get :edit, :id => @category.id, :group_id => groups(:inclusive).id
        assigns(:category).should == @category
      end
    end
  end

  describe "create" do
    it "should authorize :create on the passed category params" do
      @group = Factory(:group)
      @category = Factory(:category, :group => @group)

      @ability.should_receive(:can?).ordered.with(:create, @category).and_return(true)

      Category.stub(:new).and_return(@category)
      Group.stub(:find).and_return(@group)
      post :create, :group_id => @group.id, :category => {'name' => 'Javanese', 'depth' => '0'}
    end

    describe "with valid params" do
      it "assigns a newly created category to @category" do
        lambda {
          post :create, :category => {'name' => 'FROMSPACE', :description => "lots of junk", :depth => '0'}, :group_id => groups(:inclusive).id
          assigns(:category).should_not be_new_record
          assigns(:category).should be_valid
          assigns(:category).name.should == 'FROMSPACE'
          assigns(:category).description.should == "lots of junk"
          assigns(:category).depth.should == 0
        }.should change(Category, :count).by(1)
      end

      it "redirects to the created category" do
        post :create, :category => {'name' => 'FROMSPACE', :depth => 0}, :group_id => groups(:inclusive).id
        response.should redirect_to(group_category_url(assigns(:group), assigns(:category)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        post :create, :category => {'name' => 'FROMSPACE', :depth => 0}, :group_id => groups(:inclusive).id
        assigns(:category).creator.should == user
      end

      it "should set the group on the new category to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :category => {'name' => 'Javanese', 'depth' => '0'}

        assigns(:group).should == @group
        assigns(:category).group.should == @group
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
      @group = Factory(:group)
      @category = Factory(:category, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @category).and_return(true)

      Category.stub(:find).and_return(@category)
      Group.stub(:find).and_return(@group)
      put :update, :id => @category.id, :category => {'name' => 'ayb', :depth => "0"}, :group_id => @group.id
    end

    it "loads the requested category through current group" do
      @category = categories(:inclusive0)
      @group = @category.group
      @cats = @group.categories
      Group.stub(:find).and_return @group
      @group.should_receive(:categories).and_return @cats

      put :update, :group_id => @group.id, :id => @category.id, :category => {'name' => 'eengleesh'}

      assigns(:category).should == @category
    end

    it "assigns the requested category's depth to @depth" do
      @category = categories(:inclusive1)
      @group = groups(:inclusive)
      @category.depth.should == 1

      put :update, :group_id => @group.id, :id => @category.id, :category => {'name' => 'eengleesh'}

      assigns(:depth).should == 1
    end

    describe "with valid params" do
      it "calls update with the passed params on the requested category" do
        @category = categories(:inclusive0)
        @group = @category.group
        @group.stub(:categories).and_return Category
        Category.stub(:find).with(@category.id).and_return(@category)
        Group.stub(:find).and_return @group

        @category.should_receive(:update_attributes).with({'name' => 'ayb'}).and_return(true)

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
        assigns(:category).should == categories(:inclusive0)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    def do_destroy_on_category(category)
      post :destroy, :group_id => category.group.id, :id => category.id
    end

    it "should authorize :destroy on the passed category" do
      @group = groups(:inclusive)
      @category = categories(:inclusive0)

      @ability.should_receive(:can?).ordered.with(:destroy, @category).and_return(true)

      Group.stub(:find).and_return(@group)
      do_destroy_on_category(@category)
    end

    it "loads the category through current group" do
      @category = categories(:inclusive0)
      @group = @category.group

      @group.should_receive(:categories).and_return Category.where(:group => @group)

      Group.stub(:find).and_return @group
      post :destroy, :group_id => @group.id, :id => @category.id
    end

    it "calls destroy on the requested category" do
      @category = categories(:inclusive0)
      @group = @category.group
      @group.stub(:categories).and_return Category

      @category.should_receive(:destroy).and_return(true)

      Category.stub(:find).and_return @category
      Group.stub(:find).and_return @group
      do_destroy_on_category(@category)
    end

    it "redirects to the categories list" do
      delete :destroy, :id => categories(:inclusive0), :group_id => groups(:inclusive).id
      response.should redirect_to(group_categories_url(assigns(:group)))
    end
  end
end
