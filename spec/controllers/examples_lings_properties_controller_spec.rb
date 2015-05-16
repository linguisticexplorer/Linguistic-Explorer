require 'spec_helper'

describe ExamplesLingsPropertiesController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "show" do
    describe "assigns" do
      it "@examples_lings_property should match the passed id" do
        get :show, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
        expect(assigns(:examples_lings_property)).to eq(examples_lings_properties(:inclusive))
      end
    end

    it "@examples_lings_property should be found by id through current_group" do
      @elp = examples_lings_properties(:inclusive)
      @group = @elp.group
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:examples_lings_properties).and_return @group.examples_lings_properties

      get :show, :id => @elp.id, :group_id => @group.id
    end
  end

  describe "new" do
    it "should authorize :create on @examples_lings_property" do
      @group = FactoryGirl.create(:group)
      @elp = Example.new

      expect(@ability).to receive(:can?).ordered.with(:create, @elp).and_return(true)

      allow(ExamplesLingsProperty).to receive_message_chain(:new).and_return(@elp)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new examples_lings_property to @examples_lings_property" do
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:examples_lings_property)).to be_new_record
      end

      it "examples in current group to @examples" do
        @group = groups(:inclusive)
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:examples)).to eq(@group.examples)
      end

      it "lings_properties in the current group to @lings_properties" do
        @group = groups(:inclusive)
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:lings_properties)).to eq(@group.lings_properties.sort_by(&:description))
      end

      it "no ling_properties if a ling is passed" do
        @group = groups(:inclusive)
        get :new, :group_id => groups(:inclusive).id, :ling_id => lings(:level0).id
        expect(assigns(:lings_properties)).to eq(false)
      end
    end
  end

  describe "create" do
    it "should authorize :create on the examples_lings_property with params" do
      @group = groups(:inclusive)
      @lp = lings_properties(:level0)
      @example = FactoryGirl.create(:example, :ling => @lp.ling, :group => @group)

      @elp = ExamplesLingsProperty.new do |elp|
        elp.group = @group
        elp.example = @example
        elp.lings_property = @lp
      end

      expect(@ability).to receive(:can?).ordered.with(:create, @elp).and_return(true)

      allow(ExamplesLingsProperty).to receive_message_chain(:new).and_return(@elp)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :examples_lings_property => {'example_id' => @example.id, 'lings_property_id' => @lp.id}, :group_id => @group.id
    end

    describe "with valid params" do
      it "assigns a newly created examples_lings_property to @examples_lings_property" do
        expect {
          example = examples(:inclusive)
          lings_property = lings_properties(:inclusive)

          post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id.to_i}, :group_id => groups(:inclusive).id

          expect(assigns(:examples_lings_property)).not_to be_new_record
          expect(assigns(:examples_lings_property)).to be_valid
          expect(assigns(:examples_lings_property).example).to eq(example)
          expect(assigns(:examples_lings_property).lings_property).to eq(lings_property)
        }.to change(ExamplesLingsProperty, :count).by(1)
      end

      it "redirects to the created examples_lings_property" do
        example = examples(:inclusive)
        lings_property = lings_properties(:inclusive)

        post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id}, :group_id => groups(:inclusive).id

        expect(response).to redirect_to(group_examples_lings_property_url(assigns(:group), assigns(:examples_lings_property)))
      end

      it "should set creator to be the currently logged in user" do
        user = FactoryGirl.create(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        example = examples(:inclusive)
        lings_property = lings_properties(:inclusive)

        sign_in user
        post :create, :examples_lings_property => {'example_id' => example.id, 'lings_property_id' => lings_property.id}, :group_id => groups(:inclusive).id

        expect(assigns(:examples_lings_property).creator).to eq(user)
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)
        @lp = lings_properties(:level0)
        @example = FactoryGirl.create(:example, :ling => @lp.ling, :group => @group)

        post :create, :examples_lings_property => {'example_id' => @example.id, 'lings_property_id' => @lp.id}, :group_id => @group.id

        expect(assigns(:group)).to eq(@group)
        expect(assigns(:examples_lings_property).group).to eq(@group)
      end
    end

    describe "with invalid params" do
      it "does not save a new property" do
        expect {
          post :create, :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
          expect(assigns(:examples_lings_property)).not_to be_valid
        }.to change(ExamplesLingsProperty, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :examples_lings_property => {:example_id => nil}, :group_id => groups(:inclusive).id
        expect(response).to be_success
        expect(response).to render_template("new")
      end

      it "assigns examples from the group to @examples" do
        @example = examples(:inclusive)
        @group = @example.group
        @other_example = examples(:exclusive)

        post :create, :examples_lings_property => {:example_id => nil}, :group_id => @group.id

        expect(assigns(:examples)).to include @example
        expect(assigns(:examples)).not_to include @other_example
      end

      it "lings_properties from the current group into @lings_properties" do
        @lings_property = lings_properties(:level0)
        @group = @lings_property.group
        @other_lings_property = lings_properties(:exclusive)

        post :create, :examples_lings_property => {:example_id => nil}, :group_id => @group.id

        expect(assigns(:lings_properties)).to include @lings_property
        expect(assigns(:lings_properties)).not_to include @other_lings_property
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
      allow(Group).to receive_message_chain(:find).and_return(@group)

      do_destroy_on_examples_lings_property(@elp)
    end

    it "loads the examples_lings_property through current group" do
      @group.should_receive(:examples_lings_properties).and_return ExamplesLingsProperty.where(:group_id => @group.id)
      allow(Group).to receive_message_chain(:find).and_return @group

      do_destroy_on_examples_lings_property(@elp)
    end

    it "calls destroy on the requested examples_lings_property" do
      allow(@group).to receive_message_chain(:examples_lings_properties).and_return ExamplesLingsProperty

      @elp.should_receive(:destroy).and_return(true)

      allow(ExamplesLingsProperty).to receive_message_chain(:find).and_return @elp
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_examples_lings_property(@elp)
    end
    
    ## TODO: Redirect to the ling page once done
    it "redirects to the examples_lings_properties list" do
      delete :destroy, :id => examples_lings_properties(:inclusive), :group_id => groups(:inclusive).id
      expect(response).to redirect_to(assigns(:group))
    end
  end
end
