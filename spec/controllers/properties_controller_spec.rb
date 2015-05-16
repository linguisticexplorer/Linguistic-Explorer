require 'rails_helper'

describe PropertiesController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@properties should load through the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:properties).and_return @group.properties

      get :index, { :group_id => @group.id, :plain => true }
    end

    describe "assigns" do
      it "@properties should contain properties for the group" do
        get :index, { :group_id => groups(:inclusive).id, :plain => true }

        expect(assigns(:properties)).to include properties(:level0)
        expect(assigns(:properties)).not_to include properties(:exclusive0)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@property should match the passed id" do
        @property = properties(:valid)
        get :show, :id => @property.id, :group_id => @property.group.id
        expect(assigns(:property)).to eq @property
      end

      it "@values should contain all values associated with the property" do
        @ling = lings(:level0)
        @group = @ling.group
        @lp = lings_properties(:level0)
        expect(@lp.ling).to eq @ling
        @property = @lp.property

        get :show, { :id => @property.id, :group_id => @group.id, :letter => "l" }

        expect(assigns(:values)).to include @lp
        expect(assigns(:values).size).to eq @property.lings_properties.size
      end
    end

    it "@property should be found by id through current_group" do
      @property = properties(:level0)
      @group = @property.group
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:properties).and_return @group.properties
      expect(Group).to receive(:lings).and_return @group.lings

      get :show, :id => @property.id, :group_id => @group.id
      expect(assigns(:property)).to eq @property
    end
  end

  describe "new" do
    it "should authorize :create on @property" do
      @group = FactoryGirl.create(:group)
      @property = Property.new

      expect(@ability).to receive(:can?).ordered.with(:create, @property).and_return(true)

      allow(Property).to receive_message_chain(:new).and_return(@property)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new property to @property" do
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:property)).to be_new_record
      end

      it "@categories should be a hash with two level members" do
        get :new, :group_id => groups(:inclusive).id
        cats = assigns(:categories)

        expect(cats).to be_a Hash
        expect(cats[:depth_0]).to include categories(:inclusive0)
        expect(cats[:depth_1]).to include categories(:inclusive1)
        expect(cats[:depth_0]).not_to include categories(:exclusive0)
        expect(cats[:depth_1]).not_to include categories(:exclusive1)
      end
    end
  end

  describe "edit" do
    it "should authorize :update on @property" do
      @property = properties(:level0)
      @group = @property.group

      expect(@ability).to receive(:can?).ordered.with(:update, @property).and_return(true)

      allow(Property).to receive_message_chain(:find).and_return @property
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:properties).and_return @group.properties
      allow(Group).to receive_message_chain(:categories).and_return @group.categories
      get :edit, :id => @property.id, :group_id => @group.id
    end

    it "loads the requested property through current group" do
      @property = properties(:level0)
      @group = @property.group
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:categories).and_return @group.categories

      expect(Group).to receive(:properties).and_return @group.properties

      get :edit, :id => @property.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested property to @property" do
        @property = properties(:valid)
        get :edit, :id => @property.id, :group_id => @property.group.id
        expect(assigns(:property)).to eq @property
      end

      it "@categories should be a hash with two level members" do
        get :edit, :id => properties(:valid), :group_id => groups(:inclusive).id
        cats = assigns(:categories)

        expect(cats).to be_a Hash
        expect(cats[:depth_0]).to include categories(:inclusive0)
        expect(cats[:depth_1]).to include categories(:inclusive1)
        expect(cats[:depth_0]).not_to include categories(:exclusive0)
        expect(cats[:depth_1]).not_to include categories(:exclusive1)
      end
    end
  end

  describe "create" do
    it "should authorize :create on the property with params" do
      @property = properties(:level0)
      @group = @property.group
      @category = FactoryGirl.create(:category, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:create, @property).and_return(true)

      allow(Property).to receive_message_chain(:new).and_return(@property)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :group_id => @group.id, :property => {'name' => 'Javanese', 'category_id' => @category.id}
    end

    describe "with valid params" do
      def do_valid_create
        post :create, :property => {'name' => 'FROMSPACE', :description => "lots of junk", :category_id => categories(:inclusive0).id}, :group_id => groups(:inclusive).id
      end

      it "assigns a newly created property to @property" do
        expect {
          do_valid_create
          expect(assigns(:property)).not_to be_new_record
          expect(assigns(:property)).to be_valid
          expect(assigns(:property).name).to eq 'FROMSPACE'
          expect(assigns(:property).description).to eq "lots of junk"
          expect(assigns(:property).category).to eq categories(:inclusive0)
        }.to change(Property, :count).by(1)
      end

      it "redirects to the created property" do
        do_valid_create
        expect(response).to redirect_to(group_property_url(expect(assigns(:group)), expect(assigns(:property))))
      end

      it "should set creator to be the currently logged in user" do
        user = FactoryGirl.create(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        do_valid_create
        expect(assigns(:property).creator).to eq user
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)
        @category = FactoryGirl.create(:category, :group => @group)

        post :create, :property => {'name' => 'FROMSPACE', :description => "lots of junk", :category_id => @category.id}, :group_id => @group.id

        expect(assigns(:group)).to eq @group
        expect(assigns(:property).group).to eq @group
      end
    end

    describe "with invalid params" do
      def do_invalid_create
        post :create, :property => {'name' => ''}, :group_id => groups(:inclusive).id
      end

      it "does not save a new property" do
        expect {
          do_invalid_create
          expect(assigns(:property)).not_to be_valid
        }.to change(Property, :count).by(0)
      end

      it "@categories should be a hash with two level members" do
        do_invalid_create
        cats = assigns(:categories)
        expect(cats).to be_a Hash
        expect(cats[:depth_0]).to include categories(:inclusive0)
        expect(cats[:depth_1]).to include categories(:inclusive1)
        expect(cats[:depth_0]).not_to include categories(:exclusive0)
        expect(cats[:depth_1]).not_to include categories(:exclusive1)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        expect(response).to be_success
        expect(response).to render_template("new")
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed property" do
      @property = properties(:level0)
      @group = @property.group

      expect(@ability).to receive(:can?).ordered.with(:update, @property).and_return(true)

      allow(Property).to receive_message_chain(:find).and_return(@property)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      put :update, :id => @property.id, :property => {'name' => 'ayb'}, :group_id => @group.id
    end

    it "loads the requested property through current group" do
      @property = properties(:level0)
      @group = @property.group
      @props = @group.properties
      allow(Group).to receive_message_chain(:find).and_return @group
      expect(@group).to receive(:properties).and_return @props

      put :update, :group_id => @group.id, :id => @property.id, :property => {'name' => 'eengleesh'}

      expect(assigns(:property)).to eq @property
    end

    describe "with valid params" do
      def do_valid_update_on_property(property)
        put :update, :id => property.id, :property => {'name' => 'ayb'}, :group_id => groups(:inclusive).id
      end

      it "calls update with the passed params on the requested property" do
        @property = properties(:level0)
        new_name = "foobard"
        @group = @property.group
        allow(@group).to receive_message_chain(:properties).and_return Property
        allow(Property).to receive_message_chain(:find).and_return @property
        allow(Group).to receive_message_chain(:find).and_return @group

        expect(@property).to receive(:update_attributes).with({'name' => new_name}).and_return true

        put :update, :id => @property.id, :property => {'name' => new_name}, :stored_values => {:text => "foo"}, :group_id => @group.id
      end

      it "assigns the requested property as @property" do
        do_valid_update_on_property(properties(:valid))
        expect(assigns(:property)).to eq properties(:valid)
      end

      it "redirects to the property" do
        do_valid_update_on_property(properties(:valid))
        expect(response).to redirect_to(group_property_url(expect(assigns(:group)), properties(:valid)))
      end
    end

    describe "with invalid params" do
      def do_invalid_update
        put :update, :id => properties(:valid), :property => {'name' => ''}, :group_id => groups(:inclusive).id
      end

      it "assigns the property as @property" do
        do_invalid_update
        expect(assigns(:property)).to eq properties(:valid)
      end

      it "@categories should be a hash with two level members" do
        do_invalid_update
        cats = assigns(:categories)

        expect(cats).to be_a Hash
        expect(cats[:depth_0]).to include categories(:inclusive0)
        expect(cats[:depth_1]).to include categories(:inclusive1)
        expect(cats[:depth_0]).not_to include categories(:exclusive0)
        expect(cats[:depth_1]).not_to include categories(:exclusive1)
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        expect(response).to render_template("edit")
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

      expect(@ability).to receive(:can?).ordered.with(:destroy, @property).and_return true

      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_property(@property)
    end

    it "loads the property through current group" do
      @property = properties(:level0)
      @group = @property.group

      expect(@group).to receive(:properties).and_return Property.where(:group_id => @group.id)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @property.id
    end

    it "calls destroy on the requested property" do
      @property = properties(:level0)
      @group = @property.group
      allow(@group).to receive_message_chain(:properties).and_return Property

      expect(@property).to receive(:destroy).and_return(true)

      allow(Property).to receive_message_chain(:find).and_return @property
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_property(@property)
    end

    it "redirects to the properties list" do
      @property = properties(:level0)
      delete :destroy, :id => @property.id, :group_id => @property.group.id
      expect(response).to redirect_to(group_properties_url(@property.group))
    end
  end
end
