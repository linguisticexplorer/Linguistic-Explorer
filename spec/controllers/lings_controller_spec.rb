require 'spec_helper'

describe LingsController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "depth" do
    it "should find lings through the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)

      Group.should_receive(:lings).and_return @group.lings

      get :depth, { :group_id => @group.id, :depth => 0, :plain => true }
    end

    it "@depth should be the passed depth value" do
      depth_test_no = 0
      get :depth, { :group_id => groups(:inclusive).id, :depth => depth_test_no, :plain => true }
      assigns(:depth).should == depth_test_no
    end

    it "@lings should be an array of lings for the passed depth (0)" do
      get :depth, { :group_id => groups(:inclusive).id, :depth => 0, :plain => true, :letter => "all" }
      assigns(:lings).should include lings(:level0)
      assigns(:lings).should_not include lings(:level1)
    end

    it "@lings should be an array of lings for the passed depth (1)" do
      get :depth, { :group_id => groups(:inclusive).id, :depth => 1, :plain => true }
      assigns(:lings).should_not include lings(:level0)
      assigns(:lings).should include lings(:level1)
    end
  end

  describe "index" do
    describe "assigns" do
    it "should find lings through the current group" do
      @group = groups(:inclusive)
      Group.stub(:find).and_return(Group)
      Group.should_receive(:depths).and_return @group.depths
      Group.should_receive(:lings).exactly(@group.depths.size).times.and_return @group.lings

      get :index, { :group_id => @group.id, :plain => true }
    end

    it "@lings_by_depth should be an array of subarrays ordered by ling depth" do
        @group = groups(:inclusive)
        get :index, { :group_id => @group.id, :plain => true, :letter => "all" }

        assigns(:lings_by_depth).size.should == @group.depths.count
        assigns(:lings_by_depth)[0][0].should include lings(:level0)
        assigns(:lings_by_depth)[1][0].should include lings(:level1)
      end

      it "@lings_by_depth should be an array with current_group.depth_maximum + 1 member subarrays" do
        get :index, { :group_id => groups(:inclusive).id, :plain => true }
        assigns(:lings_by_depth).size.should == groups(:inclusive).depth_maximum + 1
      end
    end
  end

  describe "show" do
    it "@ling should be found by id through current_group" do
      @group = groups(:inclusive)
      @ling = lings(:english)
      @ling.group.should == @group

      Group.stub(:find).and_return(Group)
      Group.should_receive(:lings).and_return @group.lings
      get :show, :id => @ling.id, :group_id => @group.id

      assigns(:ling).should == @ling
    end

    it "@values should contain all values associated with the ling" do
      @property = properties(:level0)
      @group = @property.group
      @lp = lings_properties(:level0)
      @lp.property.should == @property
      @ling = @lp.ling

      get :show, :id => @ling.id, :group_id => @group.id

      assigns(:values).should include @lp
      assigns(:values).size.should == @ling.lings_properties.size
    end
  end

  describe "new" do
    def do_new_with_depth(depth)
      get :new, :group_id => groups(:inclusive).id, :depth => depth
    end

    it "should authorize :create on @ling" do
      @ling = Ling.new
      @group = Factory(:group)

      @ability.should_receive(:can?).ordered.with(:create, @ling).and_return(true)

      Ling.stub(:new).and_return(@ling)
      Group.stub(:find).and_return(@group)
      get :new, :group_id => @group.id
    end

    describe "with a depth parameter > 0" do
      it "assigns a new ling to @ling, with depth the same as the param" do
        do_new_with_depth(1)
        assigns(:ling).should be_new_record
        assigns(:ling).depth.should == 1
      end

      it "should assign @depth the value of the parameter" do
        do_new_with_depth(1)
        assigns(:depth).should == 1
      end

      it "should assign lings from current group with @depth-1 depth to @parents" do
        @group = groups(:inclusive)
        @ling = lings(:level0)
        @wrong_depth_ling = lings(:level1)

        get :new, :group_id => @group.id, :depth => 1

        @parents = assigns(:parents)
        @parents.should_not be_empty
        @parents.should include @ling
        @parents.should_not include @wrong_depth_ling
      end
    end

    describe "with a depth parameter of 0" do
      it "assigns a new ling to @ling, with depth the same as the param" do
        do_new_with_depth(0)
        assigns(:ling).should be_new_record
        assigns(:ling).depth.should == 0
      end

      it "should assign 0 to @depth" do
        do_new_with_depth(0)
        assigns(:depth).should == 0
      end
    end

    describe "without a depth parameter" do
      it "assigns a new ling to @ling, with depth 0" do
        do_new_with_depth(nil)
        assigns(:ling).should be_new_record
        assigns(:ling).depth.should == 0
      end

      it "should assign 0 to @depth" do
        do_new_with_depth(nil)
        assigns(:depth).should == 0
      end
    end
  end

  describe "edit" do
    def do_edit_on_ling(ling)
      get :edit, :group_id => groups(:inclusive).id, :id => ling.id
    end

    describe "assigns" do
      it "loads the requested ling through current group" do
        @ling = lings(:english)
        @group = @ling.group
        Group.stub(:find).and_return Group
        Group.should_receive(:lings).twice.and_return @group.lings

        get :edit, :group_id => @group.id, :id => @ling.id

        assigns(:ling).should == @ling
      end

      it "the requested ling's depth to @depth" do
        @ling = lings(:level1)
        do_edit_on_ling(@ling)
        assigns(:depth).should == @ling.depth
      end

      it "available @depth-1 depth lings for the current group to @parents" do
        @ling = lings(:level1)
        @ling.depth.should == 1
        @group = @ling.group
        @group.should_receive(:lings).twice.and_return Ling

        Ling.should_receive(:at_depth).and_return Ling.where(:depth => 0)
        Group.stub(:find).and_return @group
        get :edit, :group_id => @group.id, :id => @ling.id

        parent_depths = assigns(:parents).collect(&:depth).uniq
        parent_depths.should == [ 0 ]
      end

      it "an empty array to @parents if depth is <= 0" do
        @ling = lings(:level0)
        @ling.depth.should == 0

        do_edit_on_ling(@ling)

        assigns(:parents).should == []
      end
    end

    it "should authorize :update on the passed ling" do
      @group = Factory(:group)
      @ling = Factory(:ling, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @ling).and_return(true)

      Ling.stub(:new).and_return(@ling)
      Group.stub(:find).and_return(@group)
      get :edit, :group_id => @group.id, :id => @ling.id
    end
  end

  describe "create" do
    it "should authorize :create on the passed ling params" do
      @group = Factory(:group)
      @ling = Factory(:ling, :group => @group)

      @ability.should_receive(:can?).ordered.with(:create, @ling).and_return(true)

      Ling.stub(:new).and_return(@ling)
      Group.stub(:find).and_return(@group)
      post :create, :group_id => @group.id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}
    end

    describe "with valid params" do
      def do_valid_create
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}, :stored_values => {:description => "foo"}
      end

      it "assigns a newly created ling to @ling" do
        lambda {
          do_valid_create
          assigns(:ling).should_not be_new_record
          assigns(:ling).should be_valid
          assigns(:ling).name.should == 'Javanese'
        }.should change(Ling, :count).by(1)
      end

      it "creates and associates passed stored values" do
        lambda {
          do_valid_create
          assigns(:ling).stored_value(:description).should == 'foo'
        }.should change(StoredValue, :count).by(1)
      end

      it "redirects to the created ling" do
        do_valid_create
        response.should redirect_to(group_ling_url(assigns(:group), assigns(:ling)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user

        do_valid_create

        assigns(:ling).creator.should == user
      end

      it "should set the group on the new ling to current group" do
        @group = groups(:inclusive)

        post :create, :group_id => @group.id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}, :stored_values => {:description => "foo"}

        assigns(:group).should == @group
        assigns(:ling).group.should == @group
      end
    end

    describe "with invalid params" do
      def do_invalid_create
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => '', 'depth' => 1}, :stored_values => {:description => "foo"}
      end

      it "does not create passed stored values" do
        lambda { do_invalid_create }.should change(StoredValue, :count).by(0)
      end

      it "does not save a new ling" do
        lambda {
          do_invalid_create
          assigns(:ling).should_not be_valid
        }.should change(Ling, :count).by(0)
      end

      it "re-renders the 'new' template" do
        do_invalid_create
        response.should be_success
        response.should render_template("new")
      end

      describe "assigns" do
        it "the attempted ling's depth to @depth" do
          do_invalid_create
          assigns(:depth).should == 1
        end

        it "available @depth-1 depth lings to @parents" do
          do_invalid_create
          parent_depths = assigns(:parents).collect(&:depth)
          parent_depths.uniq.size.should == 1
          parent_depths.first.should == 0
        end
      end
    end
  end

  describe "update" do
    it "should authorize :update on the passed ling" do
      @group = Factory(:group)
      @ling = Factory(:ling, :group => @group)

      @ability.should_receive(:can?).ordered.with(:update, @ling).and_return(true)

      Ling.stub(:find).and_return(@ling)
      Group.stub(:find).and_return(@group)
      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}
    end

    it "loads the requested ling through current group" do
      @ling = lings(:english)
      @group = @ling.group
      @lings = @group.lings
      Group.stub(:find).and_return @group
      @group.should_receive(:lings).and_return @lings

      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}

      assigns(:ling).should == @ling
    end

    it "assigns the requested ling's depth to @depth" do
      @ling = lings(:level1)
      @group = groups(:inclusive)
      @ling.depth.should == 1

      put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => 'eengleesh'}

      assigns(:depth).should == 1
    end

    describe "with valid params" do
      it "updates the requested ling" do
        @ling = lings(:english)
        @group = @ling.group
        new_name = 'eengleesh'
        @ling.name.should_not == new_name

        put :update, :group_id => @group.id, :id => @ling.id, :ling => {'name' => new_name}

        @ling.reload.name.should == new_name
      end

      it "creates or updates passed stored values" do
        first_value = "foo"
        second_value = "bar"
        ling = lings(:level0)

        #test creation of a new value for key 'description'
        put :update, :id => ling.id, :ling => {'name' => 'ee'}, :group_id => ling.group.id, :stored_values => {:description => first_value}
        ling.reload.stored_value(:description).should == first_value

        #now do a bad update with 'description' set as the new value
        put :update, :id => ling.id, :ling => {'name' => "ee"}, :group_id => ling.group.id, :stored_values => {:description => second_value}
        ling.reload.stored_value(:description).should == second_value
      end

      it "redirects to the ling" do
        put :update, :group_id => groups(:inclusive).id, :id => lings(:english)
        response.should redirect_to(group_ling_url(assigns(:group), lings(:english)))
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
        ling.reload.stored_value(:description).should == first_value

        #now do a bad update with 'description' set as the new value
        put :update, :id => ling.id, :ling => {'name' => ""}, :group_id => ling.group.id, :stored_values => {:description => second_value}
        ling.reload.stored_value(:description).should == first_value
      end

      it "assigns available @depth-1 depth lings to @parents" do
        do_invalid_update
        assigns(:parents).map{|ling| ling.depth}.uniq.should == [0]
      end

      it "re-renders the 'edit' template" do
        do_invalid_update
        response.should render_template("edit")
      end
    end
  end

  describe "destroy" do
    def do_destroy_on_ling(ling)
      delete :destroy, :group_id => ling.group.id, :id => ling.id
    end

    it "should authorize :destroy on the passed ling" do
      @group = groups(:inclusive)
      @ling = Factory(:ling, :name => "thosewhoareabouttodie", :group => @group)

      @ability.should_receive(:can?).ordered.with(:destroy, @ling).and_return(true)

      do_destroy_on_ling(@ling)
    end

    it "loads the ling through current group" do
      @ling = lings(:english)
      @group = @ling.group

      @group.should_receive(:lings).and_return Ling.where(:group => @group)

      Group.stub(:find).and_return @group
      delete :destroy, :group_id => @group.id, :id => @ling.id
    end

    it "calls destroy on the requested ling" do
      @ling = lings(:english)
      @group = @ling.group
      @group.stub(:lings).and_return Ling

      @ling.should_receive(:destroy).and_return(true)

      Ling.stub(:find).and_return @ling
      Group.stub(:find).and_return @group
      do_destroy_on_ling(@ling)
    end

    it "assigns the deleted ling's depth to @depth" do
      do_destroy_on_ling(lings(:level1))
      assigns(:depth).should == 1
    end

    it "redirects to the lings list for the appropriate depth" do
      do_destroy_on_ling(lings(:level1))
      response.should redirect_to(group_lings_depth_url(assigns(:group), assigns(:depth)))
    end
  end
end
