require 'rails_helper'

describe ExamplesController do
  before do
    allow_message_expectations_on_nil
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "index" do
    it "@examples should load through the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:examples).and_return @group.examples

      get :index, :group_id => @group.id
    end

    describe "assigns" do
      it "@examples should contain examples from the group" do
        get :index, :group_id => groups(:inclusive).id

        expect(assigns(:examples)).to include examples(:inclusive)
        expect(assigns(:examples)).not_to include examples(:exclusive)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@examples should match the passed id" do
        @example = examples(:onceuponatime)
        get :show, :id => @example.id, :group_id => @example.group.id
        expect(assigns(:example)).to eq(@example)
      end
    end

    it "@example should be found by id through current_group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:examples).and_return @group.examples

      get :show, :id => @example.id, :group_id => @group.id
      expect(assigns(:example)).to eq(@example)
    end
  end

  describe "new" do
    it "should authorize :create on @example" do
      @group = FactoryGirl.create(:group)
      @example = Example.new

      expect(@ability).to receive(:can?).ordered.with(:create, @example).and_return(true)

      allow(Example).to receive_message_chain(:new).and_return(@example)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "assigns" do
      it "a new example to @example" do
        get :new, :group_id => groups(:inclusive).id
        expect(assigns(:example)).to be_new_record
      end

    end
  end

  describe "edit" do
    it "should authorize :update on @example" do
      @example = examples(:onceuponatime)
      @group = @example.group

      expect(@ability).to receive(:can?).ordered.with(:update, @example).and_return(true)

      allow(Example).to receive_message_chain(:find).and_return @example
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:examples).and_return @group.examples
      allow(Group).to receive_message_chain(:lings).and_return @group.lings
      get :edit, :id => @example.id, :group_id => @group.id
    end

    it "loads the requested example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      allow(Group).to receive_message_chain(:find).and_return Group
      allow(Group).to receive_message_chain(:lings).and_return @group.lings

      expect(Group).to receive(:examples).and_return @group.examples

      get :edit, :id => @example.id, :group_id => @group.id
    end

    describe "assigns" do
      it "the requested example to @example" do
        @example = examples(:onceuponatime)
        get :edit, :id => @example.id, :group_id => @example.group.id
        expect(assigns(:example)).to eq(@example)
      end

      it "should get related ling and property for an example by default" do
        get :edit, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id

        expect(assigns(:ling)).to eq examples(:onceuponatime).ling
        expect(assigns(:property)).to be_nil
        expect(assigns(:lp)).to be_nil
      end

      it "should get passed ling, property and lp if ids are passed" do
        get :edit, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id, :ling_id => lings(:level0), :prop_id => properties(:level0), :lp_id => lings_properties(:level0)

        expect(assigns(:ling)).to eq lings(:level0)
        expect(assigns(:property)).to eq properties(:level0)
        expect(assigns(:lp)).to eq lings_properties(:level0)
      end
    end
  end

  describe "create" do
    it "should authorize :create on the example with params" do
      @group = FactoryGirl.create(:group)
      @example = FactoryGirl.create(:example, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:create, @example).and_return(true)

      allow(Example).to receive_message_chain(:new).and_return(@example)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :group_id => @group.id, :example => {'name' => 'Javanese', 'lp_id' => '20'} 
    end

    describe "with valid params and valid stored_values" do
      it "assigns a newly created example to @example" do
        expect {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:description => "foo"}, :group_id => groups(:inclusive).id
          expect(assigns(:example)).to be_new_record
          expect(assigns(:example)).to be_valid
          expect(assigns(:example).name).to eq('Javanese')
        }.to change(Example, :count).by(1)
      end

      it "creates and associates passed stored values" do
        expect {
          post :create, :example => {'name' => 'Javanese'}, :stored_values => {:description => "foo"}, :group_id => groups(:inclusive).id
          expect(assigns(:example).stored_value(:description)).to eq('foo')
        }.to change(StoredValue, :count).by(1)
      end

      it "redirects to the created example" do
        post :create, :example => {'name' => 'Javanese'}, :group_id => groups(:inclusive).id
        expect(response).to redirect_to(group_example_url(assigns(:group), assigns(:example)))
      end

      it "should set creator to be the currently logged in user" do
        user = FactoryGirl.create(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user

        post :create, :example => {'name' => 'Javanese'}, :group_id => groups(:inclusive).id

        expect(assigns(:example).creator).to eq(user)
      end

      it "should set the group to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :example => {'name' => 'Javanese'}

        expect(assigns(:group)).to eq(@group)
        expect(assigns(:example).group).to eq(@group)
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed example" do
      @group = FactoryGirl.create(:group)
      @example = FactoryGirl.create(:example, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:update, @example).and_return(true)

      allow(Example).to receive_message_chain(:find).and_return(@example)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      put :update, :id => @example.id, :example => {'name' => 'ayb'}, :group_id => @group.id
    end

    it "loads the requested example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group
      @exes = @group.examples
      allow(Group).to receive_message_chain(:find).and_return @group
      expect(@group).to receive(:examples).and_return @exes

      put :update, :group_id => @group.id, :id => @example.id, :example => {'name' => 'eengleesh'}

      expect(assigns(:example)).to eq(@example)
    end

    describe "with valid params" do
      it "calls update with the passed params on the requested example" do
        @example = examples(:onceuponatime)
        new_name = "foobard"
        @group = @example.group
        allow(@group).to receive_message_chain(:examples).and_return Example
        allow(Example).to receive_message_chain(:find).with(@example.id.to_s).and_return(@example)
        allow(Group).to receive_message_chain(:find).and_return @group

        expect(@example).to receive(:update_attributes).with({'name' => new_name}).and_return(true)

        put :update, :id => @example.id, :example => {'name' => new_name}, :stored_values => {:description => "foo"}, :group_id => @example.group.id
      end

      it "creates or updates passed stored values" do
        example = examples(:onceuponatime)
        #test creation of a new value of key 'description'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:description => "foo"}
        expect(example.reload.stored_value(:description)).to eq('foo')
        #now update 'description' value to be 'bar'
        put :update, :id => example.id, :example => {'name' => 'eengleesh'}, :group_id => example.group.id, :stored_values => {:description => "bar"}
        expect(example.reload.stored_value(:description)).to eq('bar')
      end

      it "assigns the requested example as @example" do
        put :update, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        expect(assigns(:example)).to eq(examples(:onceuponatime))
      end

      it "redirects to the example" do
        put :update, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
        expect(response).to redirect_to(group_example_url(assigns(:group), examples(:onceuponatime)))
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_example(example)
      delete :destroy, :group_id => example.group.id, :id => example.id
    end

    it "should authorize :destroy on the passed example" do
      @example = examples(:onceuponatime)
      @group = @example.group

      expect(@ability).to receive(:can?).ordered.with(:destroy, @example).and_return(true)

      allow(Group).to receive_message_chain(:find).and_return(@group)
      do_destroy_on_example(@example)
    end

    it "loads the example through current group" do
      @example = examples(:onceuponatime)
      @group = @example.group

      expect(@group).to receive(:examples).and_return Example.where(:group_id => @group.id)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @example.id
    end

    it "calls destroy on the requested example" do
      @example = examples(:onceuponatime)
      @group = @example.group
      allow(@group).to receive_message_chain(:examples).and_return Example

      expect(@example).to receive(:destroy).and_return(true)

      allow(Example).to receive_message_chain(:find).and_return @example
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_example(@example)
    end

    it "redirects to the examples list" do
      delete :destroy, :id => examples(:onceuponatime), :group_id => groups(:inclusive).id
      expect(response).to redirect_to(group_examples_url(assigns(:group)))
    end
  end
end
