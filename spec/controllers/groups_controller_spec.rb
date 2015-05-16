require 'spec_helper'

describe GroupsController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "index" do
    describe "without a group_id parameter" do
      it "@groups should contain accessible groups for signed in user" do
        allow(@controller).to receive_message_chain(:user_signed_in?).and_return(true)
        @group = FactoryGirl.create(:group)
        expect(Group).to receive(:accessible_by).with(@ability).and_return( [@group] )
        get :index
        expect(assigns(:groups)).to include @group
      end

      it "@groups should contain accessible groups" do
        allow(@controller).to receive_message_chain(:user_signed_in?).and_return(false)
        @group = FactoryGirl.create(:group)
        expect(Group).to receive(:public).and_return( [@group] )
        get :index
        expect(assigns(:groups)).to include @group
      end
    end

    describe "with a group_id parameter" do
      it "should authorize :show on group" do
        @ability = Ability.new(nil)
        @group = FactoryGirl.create(:group)
        expect(@ability).to receive(:can?).with(:show, @group).and_return true
        allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
        allow(Group).to receive_message_chain(:find).and_return(@group)
        get :index, :group_id => @group.id
      end

      it "should redirect to show for that group if valid" do
        get :index, :group_id => groups(:inclusive).id
        expect(response).to redirect_to(group_path(groups(:inclusive)))
        expect(assigns[:group]).to eq(groups(:inclusive))
      end

      it "should render index as normal if invalid" do
        get :index, :group_id => "invalid-id"
        expect(response).not_to redirect_to(groups_path + "/invalid-id")
        expect(assigns[:group]).to be_nil
      end
    end
  end

  describe "show" do
    it "should authorize :show on group" do
      @ability = Ability.new(nil)
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:show, @group).and_return true
      allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :show, :id => @group.id
    end

    describe "assigns" do
      it "@group should match the requested group id" do
        get :show, :id => groups(:inclusive).id
        expect(assigns(:group)).to eq(groups(:inclusive))
      end
    end
  end

  describe "info" do
    it "should authorize :show on group" do
      @ability = Ability.new(nil)
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:show, @group).and_return true
      allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :info, :id => @group.id
    end

    describe "assigns" do
      it "@group should match the requested group id" do
        get :info, :id => groups(:inclusive).id
        expect(assigns(:group)).to eq(groups(:inclusive))
      end
    end
  end

  describe "new" do
    def do_new
      get :new
    end

    it "should authorize :create on group" do
      @group = FactoryGirl.create(:group)
      @ability = Ability.new(nil)
      expect(Group).to receive(:new).and_return(@group)
      expect(@ability).to receive(:can?).with(:create, @group).and_return true
      allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
      do_new
    end

    describe "assigns" do
      it "a new group to @group" do
        do_new
        expect(assigns(:group)).to be_new_record
      end
    end
  end

  describe "edit" do
    it "should authorize :update on group" do
      @ability = Ability.new(nil)
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:update, @group).and_return true
      allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :edit, :id => @group.id
    end

    describe "assigns" do
      it "the requested group to @group" do
        get :edit, :id => groups(:inclusive).id
        expect(assigns(:group)).to eq(groups(:inclusive))
      end
    end
  end

  describe "create" do
    def do_create_with_params(params)
      post :create, :group => params
    end

    it "should authorize :create on group" do
      @ability = Ability.new(nil)
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:create, @group).and_return true
      allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
      allow(Group).to receive_message_chain(:new).and_return(@group)
      group_params = {'name' => 'TheBestTheBestTheBest'}
      do_create_with_params(group_params)
    end

    describe "with valid params" do
      it "assigns a newly created group to @group" do
        group_params = {'name' => 'TheBestTheBestTheBest'}
        @group = FactoryGirl.create(:group)
        expect(Group).to receive(:new).with(group_params).and_return(@group)
        do_create_with_params(group_params)
      end

      it "redirects to the created group" do
        @group = groups(:inclusive)
        group_params = {:name => 'NewGroup'}
        expect(Group).to receive(:new).and_return(@group)

        do_create_with_params(group_params)
        expect(assigns[:group]).to eq(@group)
        expect(response).to redirect_to(group_url(assigns[:group]))
      end
    end

    describe "with invalid params" do
      it "does not save a new group" do
        expect {
          invalid_params = {'name' => ''}
          do_create_with_params(invalid_params)
          expect(assigns(:group)).not_to be_valid
        }.expect change(Group, :count).by(0)
      end

      it "re-renders the 'new' template" do
        invalid_params = {'name' => ''}
        do_create_with_params(invalid_params)
        expect(response).to be_success
        expect(response).to render_template("new")
      end
    end
  end

  describe "update" do
    def do_update_on_group_with_params(group, params)
      put :update, :id => group.id, :group => params
    end

    it "should authorize :update on the passed group" do
      params = {'name' => 'lamegroup'}
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:update, @group).and_return(true)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      do_update_on_group_with_params(@group, params)
    end

    describe "with valid params" do
      it "updates the requested group" do
        group = groups(:inclusive)
        group.name.should_not eq('number1group')
        params = {'name' => 'number1group'}

        do_update_on_group_with_params(group, params)

        group.reload
        expect(group.name).to eq('number1group')
      end

      it "assigns the requested group as @group" do
        @group = groups(:inclusive)
        do_update_on_group_with_params(@group, {})
        expect(assigns(:group)).to eq(@group)
      end

      it "redirects to the group" do
        @group = groups(:inclusive)
        do_update_on_group_with_params(@group, {})
        expect(response).to redirect_to(group_url(@group))
      end
    end

    describe "with invalid params" do
      it "assigns the group as @group" do
        @group = groups(:inclusive)
        invalid_params = {'name' => ''}
        do_update_on_group_with_params(@group, invalid_params)
        expect(assigns(:group)).to eq(@group)
      end

      it "re-renders the 'edit' template" do
        do_update_on_group_with_params(groups(:inclusive), {'name' => ''})
        expect(response).to render_template("edit")
      end
    end
  end

  describe "destroy" do
    it "should authorize :destroy on the passed group" do
      @group = FactoryGirl.create(:group)
      expect(@ability).to receive(:can?).with(:destroy, @group).and_return(true)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      delete :destroy, :id => @group.id
    end

    it "calls destroy on the requested group" do
      group_id = groups(:inclusive).id
      Group.find(group_id).should_not be_nil
      delete :destroy, :id => group_id
      Group.find_by_id(group_id).should be_nil
    end

    it "redirects to the groups list" do
      delete :destroy, :id => groups(:inclusive).id
      expect(response).to redirect_to(groups_url)
    end
  end
end
