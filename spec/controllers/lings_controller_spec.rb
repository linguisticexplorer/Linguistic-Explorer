require 'rails_helper'

describe LingsController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "depth" do
    it "should find lings through the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)

      expect(Group).to receive(:lings).and_return @group.lings

      get :depth, { :group_id => @group.id, :depth => 0, :plain => true }
    end

    it "@depth should be the passed depth value" do
      depth_test_no = 0
      get :depth, { :group_id => groups(:inclusive).id, :depth => depth_test_no, :plain => true }
      expect(assigns(:depth)).to eq depth_test_no
    end

    it "@lings should be an array of lings for the passed depth (0)" do
      get :depth, { :group_id => groups(:inclusive).id, :depth => 0, :plain => true, :letter => "all" }
      expect(assigns(:lings)).to include lings(:level0)
      expect(assigns(:lings)).not_to include lings(:level1)
    end

    it "@lings should be an array of lings for the passed depth (1)" do
      get :depth, { :group_id => groups(:inclusive).id, :depth => 1, :plain => true }
      expect(assigns(:lings)).not_to include lings(:level0)
      expect(assigns(:lings)).to include lings(:level1)
    end
  end

  describe "index" do
    describe "assigns" do
    it "should find lings through the current group" do
      @group = groups(:inclusive)
      allow(Group).to receive_message_chain(:find).and_return(Group)
      expect(Group).to receive(:depths).and_return @group.depths
      expect(Group).to receive(:lings).exactly(@group.depths.size).times.and_return @group.lings

      get :index, { :group_id => @group.id, :plain => true }
    end

    it "@lings_by_depth should be an array of subarrays ordered by ling depth" do
        @group = groups(:inclusive)
        get :index, { :group_id => @group.id, :plain => true, :letter => "all" }

        expect(assigns(:lings_by_depth).size).to eq @group.depths.count
        expect(assigns(:lings_by_depth)[0][0]).to include lings(:level0)
        expect(assigns(:lings_by_depth)[1][0]).to include lings(:level1)
      end

      it "@lings_by_depth should be an array with current_group.depth_maximum + 1 member subarrays" do
        get :index, { :group_id => groups(:inclusive).id, :plain => true }
        expect(assigns(:lings_by_depth).size).to eq groups(:inclusive).depth_maximum + 1
      end
    end
  end

  describe "show" do
    it "@ling should be found by id through current_group" do
      @group = groups(:inclusive)
      @ling = lings(:english)
      expect(@ling.group).to eq @group

      allow(Group).to receive_message_chain(:find).and_return(Group)
      expect(Group).to receive(:lings).and_return @group.lings
      get :show, :id => @ling.id, :group_id => @group.id

      expect(assigns(:ling)).to eq @ling
    end

    it "@values should contain all values associated with the ling" do
      @property = properties(:level0)
      @group = @property.group
      @lp = lings_properties(:level0)
      expect(@lp.property).to eq @property
      @ling = @lp.ling

      get :show, :id => @ling.id, :group_id => @group.id

      expect(assigns(:values)).to include @lp
      expect(assigns(:values).size).to eq @ling.lings_properties.size
    end
  end

  describe "new" do
    def do_new_with_depth(depth)
      get :new, :group_id => groups(:inclusive).id, :depth => depth
    end

    it "should authorize :create on @ling" do
      @ling = Ling.new
      @group = FactoryGirl.create(:group)

      expect(@ability).to receive(:can?).ordered.with(:create, @ling).and_return(true)

      allow(Ling).to receive_message_chain(:new).and_return(@ling)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "with a depth parameter > 0" do
      it "assigns a new ling to @ling, with depth the same as the param" do
        do_new_with_depth(1)
        expect(assigns(:ling)).to be_new_record
        expect(assigns(:ling).depth).to eq 1
      end

      it "should assign @depth the value of the parameter" do
        do_new_with_depth(1)
        expect(assigns(:depth)).to eq 1
      end

      it "should assign lings from current group with @depth-1 depth to @parents" do
        @group = groups(:inclusive)
        @ling = lings(:level0)
        @wrong_depth_ling = lings(:level1)

        get :new, :group_id => @group.id, :depth => 1

        @parents = assigns(:parents)
        expect(@parents).not_to be_empty
        expect(@parents).to include @ling
        expect(@parents).not_to include @wrong_depth_ling
      end
    end

    describe "with a depth parameter of 0" do
      it "assigns a new ling to @ling, with depth the same as the param" do
        do_new_with_depth(0)
        expect(assigns(:ling)).to be_new_record
        expect(assigns(:ling).depth).to eq 0
      end

      it "should assign 0 to @depth" do
        do_new_with_depth(0)
        expect(assigns(:depth)).to eq 0
      end
    end

    describe "without a depth parameter" do
      it "assigns a new ling to @ling, with depth 0" do
        do_new_with_depth(nil)
        expect(assigns(:ling)).to be_new_record
        expect(assigns(:ling).depth).to eq 0
      end

      it "should assign 0 to @depth" do
        do_new_with_depth(nil)
        expect(assigns(:depth)).to eq 0
      end
    end
  end

  describe "edit" do
    def do_edit_on_ling(ling)
      get :edit, :group_id => groups(:inclusive).id, :id => ling.id
    end

    describe "assigns" do

      before { sign_in_as_group_admin }

      it "loads the requested ling through current group" do
        @ling = lings(:english)
        @group = @ling.group
        group_membership = @user.memberships.select { |m| m.group.id == @group.id }.first

        allow(Membership).to receive_message_chain(:group_admin?).and_return true
        allow(Group).to receive_message_chain(:find).and_return Group
        allow(Group).to receive_message_chain(:membership_for).and_return group_membership
        expect(Group).to receive(:lings).twice.and_return @group.lings

        get :edit, :group_id => @group.id, :id => @ling.id

        expect(assigns(:ling)).to eq @ling
      end

      it "the requested ling's depth to @depth" do
        @ling = lings(:level1)
        do_edit_on_ling(@ling)
        expect(assigns(:depth)).to eq @ling.depth
      end

      it "available @depth-1 depth lings for the current group to @parents" do
        @ling = lings(:level1)
        expect(@ling.depth).to eq 1
        @group = @ling.group
        expect(@group).to receive(:lings).twice.and_return Ling

        expect(Ling).to receive(:at_depth).and_return Ling.where(:depth => 0)
        allow(Group).to receive_message_chain(:find).and_return @group
        get :edit, :group_id => @group.id, :id => @ling.id

        parent_depths = assigns(:parents).collect(&:depth).uniq
        expect(parent_depths).to eq [ 0 ]
      end

      it "an empty array to @parents if depth is <= 0" do
        @ling = lings(:level0)
        expect(@ling.depth).to eq 0

        do_edit_on_ling(@ling)

        expect(assigns(:parents)).to eq []
      end
    end

    it "should authorize :update on the passed ling" do
      @group = FactoryGirl.create(:group)
      @ling = FactoryGirl.create(:ling, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:update, @ling).and_return(true)

      allow(Ling).to receive_message_chain(:new).and_return(@ling)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      get :edit, :group_id => @group.id, :id => @ling.id
    end
  end

  describe "create" do

    before { sign_in_as_group_admin }

    it "should authorize :create on the passed ling params" do
      @group = FactoryGirl.create(:group)
      @ling = FactoryGirl.create(:ling, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:create, @ling).and_return(true)

      allow(Ling).to receive_message_chain(:new).and_return(@ling)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      post :create, :group_id => @group.id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}
    end

    describe "with valid params" do
      def do_valid_create
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}, :stored_values => {:description => "foo"}
      end

      it "assigns a newly created ling to @ling" do
        expect {
          do_valid_create
          expect(assigns(:ling)).not_to be_new_record
          expect(assigns(:ling)).to be_valid
          expect(assigns(:ling).name).to eq 'Javanese'
        }.to change(Ling, :count).by(1)
      end

      it "creates and associates passed stored values" do
        expect {
          do_valid_create
          expect(assigns(:ling).stored_value(:description)).to eq 'foo'
        }.to change(StoredValue, :count).by(1)
      end

      it "redirects to the created ling" do
        do_valid_create
        expect(response).to redirect_to(group_ling_url(assigns(:group), assigns(:ling)))
      end

      it "should set creator to be the currently logged in user" do
        do_valid_create

        expect(assigns(:ling).creator).to eq @user
      end

      it "should set the group on the new ling to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}, :stored_values => {:description => "foo"}

        expect(assigns(:group)).to eq @group
        expect(assigns(:ling).group).to eq @group
      end
    end

    describe "with invalid params" do
      def do_invalid_create
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => '', 'depth' => 1}, :stored_values => {:description => "foo"}
      end

      it "does not create passed stored values" do
        expect { do_invalid_create }.to change(StoredValue, :count).by(0)
      end

      it "does not save a new ling" do
        expect {
          do_invalid_create
          expect(assigns(:ling)).not_to be_valid
        }.to change(Ling, :count).by(0)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        expect(response).to be_success
        expect(response).to render_template("new")
      end

      describe "assigns" do
        it "the attempted ling's depth to @depth" do
          do_invalid_create
          expect(assigns(:depth)).to eq 1
        end

        it "available @depth-1 depth lings to @parents" do
          do_invalid_create
          parent_depths = assigns(:parents).collect(&:depth)
          expect(parent_depths.uniq.size).to eq 1
          expect(parent_depths.first).to eq 0
        end
      end
    end
  end

  describe "update" do

    before { sign_in_as_group_admin }

    it "should authorize :update on the passed ling" do
      @group = FactoryGirl.create(:group)
      @ling = FactoryGirl.create(:ling, :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:update, @ling).and_return(true)

      allow(Ling).to receive_message_chain(:find).and_return(@ling)
      allow(Group).to receive_message_chain(:find).and_return(@group)
      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}
    end

    it "loads the requested ling through current group" do
      @ling = lings(:english)
      @group = @ling.group
      @lings = @group.lings
      allow(Group).to receive_message_chain(:find).and_return @group
      expect(@group).to receive(:lings).and_return @lings

      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}

      expect(assigns(:ling)).to eq @ling
    end

    it "assigns the requested ling's depth to @depth" do
      @ling = lings(:level1)
      @group = groups(:inclusive)
      expect(@ling.depth).to eq 1

      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}

      expect(assigns(:depth)).to eq 1
    end

    describe "with valid params" do
      it "updates the requested ling" do
        @ling = lings(:english)
        @group = @ling.group
        new_name = 'eengleesh'
        expect(@ling.name).not_to eq new_name

        put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => new_name}

        expect(@ling.reload.name).to eq new_name
      end

      it "creates or updates passed stored values" do
        first_value = "foo"
        second_value = "bar"
        ling = lings(:level0)

        #test creation of a new value for key 'description'
        put :update, :id => ling.id, :ling => {'name' => 'ee'}, :group_id => ling.group.id, :stored_values => {:description => first_value}
        expect(ling.reload.stored_value(:description)).to eq first_value

        #now do a bad update with 'description' set as the new value
        put :update, :id => ling.id, :ling => {'name' => "ee"}, :group_id => ling.group.id, :stored_values => {:description => second_value}
        expect(ling.reload.stored_value(:description)).to eq second_value
      end

      it "redirects to the ling" do
        put :update, :group_id => groups(:inclusive).id, :id => lings(:english)
        expect(response).to redirect_to(group_ling_url(assigns(:group), lings(:english)))
      end
    end

    describe "with invalid params" do
      def do_invalid_update
        put :update, :group_id => groups(:inclusive).id, :id => lings(:level1), :ling => {'name' => ''}
      end

      it "does not create or update for passed stored values" do
        first_value = "foo"
        second_value = "bar"
        ling = lings(:level0)

        #test creation of a new value for key 'description'
        put :update, :id => ling.id, :ling => {'name' => 'ee'}, :group_id => ling.group.id, :stored_values => {:description => first_value}
        expect(ling.reload.stored_value(:description)).to eq first_value

        #now do a bad update with 'description' set as the new value
        put :update, :id => ling.id, :ling => {'name' => ""}, :group_id => ling.group.id, :stored_values => {:description => second_value}
        expect(ling.reload.stored_value(:description)).to eq first_value
      end

      it "assigns available @depth-1 depth lings to @parents" do
        do_invalid_update
        expect(assigns(:parents).map{|ling| ling.depth}.uniq).to eq [0]
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        expect(response).to render_template("edit")
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_ling(ling)
      delete :destroy, :group_id => ling.group.id, :id => ling.id
    end

    before { sign_in_as_group_admin }

    it "should authorize :destroy on the passed ling" do
      @group = groups(:inclusive)
      @ling = FactoryGirl.create(:ling, :name => "thosewhoareabouttodie", :group => @group)

      expect(@ability).to receive(:can?).ordered.with(:destroy, @ling).and_return(true)

      do_destroy_on_ling(@ling)
    end

    it "loads the ling through current group" do
      @ling = lings(:english)
      @group = @ling.group

      expect(@group).to receive(:lings).and_return Ling.where(:group_id => @group.id)

      allow(Group).to receive_message_chain(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @ling.id
    end

    it "calls destroy on the requested ling" do
      @ling = lings(:english)
      @group = @ling.group
      allow(@group).to receive_message_chain(:lings).and_return Ling

      expect(@ling).to receive(:destroy).and_return(true)

      allow(Ling).to receive_message_chain(:find).and_return @ling
      allow(Group).to receive_message_chain(:find).and_return @group
      do_destroy_on_ling(@ling)
    end

    it "assigns the deleted ling's depth to @depth" do
      do_destroy_on_ling(lings(:level1))
      expect(assigns(:depth)).to eq 1
    end

    it "redirects to the lings list for the appropriate depth" do
      do_destroy_on_ling(lings(:level1))
      expect(response).to redirect_to(group_lings_depth_url(assigns(:group), assigns(:depth)))
    end
  end
end
