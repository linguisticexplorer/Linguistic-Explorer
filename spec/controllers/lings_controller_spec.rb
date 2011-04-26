require 'spec_helper'

describe LingsController do
  describe "depth" do
    it "@depth should be the passed depth value" do
      depth_test_no = 0
      get :depth, :group_id => groups(:inclusive).id, :depth => depth_test_no
      assigns(:depth).should == depth_test_no
    end

    it "@lings should be an array of lings for the passed depth (0)" do
      get :depth, :group_id => groups(:inclusive).id, :depth => 0
      assigns(:lings).should include lings(:level0)
      assigns(:lings).should_not include lings(:level1)
    end

    it "@lings should be an array of lings for the passed depth (1)" do
      get :depth, :group_id => groups(:inclusive).id, :depth => 1
      assigns(:lings).should_not include lings(:level0)
      assigns(:lings).should include lings(:level1)
    end
  end

  describe "index" do
    describe "assigns" do
      it "@lings_by_depth should be an array of subarrays ordered by ling depth" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:lings_by_depth)[0].should include lings(:level0)
        assigns(:lings_by_depth)[1].should include lings(:level1)
      end

      it "@lings_by_depth should be an array with current_group.depth_maximum + 1 member subarrays" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:lings_by_depth).size.should == groups(:inclusive).depth_maximum + 1
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@ling should match the passed id" do
        get :show, :group_id => groups(:inclusive).id, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end
    end

    it "should authorize read on @ling" do
      @ling = lings(:english)
      @group = @ling.group
      @user = Factory(:user, :name => "auth-tester", :email => "auth@test.com", :access_level => User::USER)
      @ability = Ability.new(@user)
  		Ability.stub(:new).and_return(@ability)
      Ling.stub(:find).and_return(@ling)
      @ability.should_receive(:can?).ordered.with(:show, @group).and_return(true)
      @ability.should_receive(:can?).ordered.with(:read, @ling).and_return(true)

      get :show, :group_id => @group.id, :id => @ling.id

      response.should render_template :show
    end
  end

  describe "new" do
    it "should authorize :new on @ling" do
      @user = Factory(:user, :email => "auth@test.com", :access_level => User::USER)
      @group = Factory(:group)
      @ling = Ling.new
      @ability = Ability.new(@user)
  		Ability.stub(:new).and_return(@ability)
      Ling.stub(:new).and_return(@ling)
      Group.stub(:find).and_return(@group)
      @ability.should_receive(:can?).ordered.with(:show, @group).and_return(true)
      @ability.should_receive(:can?).ordered.with(:new, @ling).and_return(true)

      get :new, :group_id => @group.id

      response.should render_template :new
    end

    describe "with a depth parameter > 0" do
      it "assigns a new ling to @ling, with depth the same as the param" do
        get :new, :group_id => groups(:inclusive).id, :depth => 1
        assigns(:ling).should be_new_record
        assigns(:ling).depth.should == 1
      end

      it "should assign @depth the value of the parameter" do
        get :new, :group_id => groups(:inclusive).id, :depth => 1
        assigns(:depth).should == 1
      end

      it "should assign lings of @depth-1 depth to @parents" do
        get :new, :group_id => groups(:inclusive).id, :depth => 1
        assigns(:parents).map{|ling| ling.depth}.uniq.should == [0]
      end
    end

    describe "with a depth parameter of 0" do
      it "should assign 0 to @depth" do
        get :new, :group_id => groups(:inclusive).id, :depth => 0
        assigns(:depth).should == 0
      end
    end

    describe "without a depth parameter" do
      it "assigns a new ling to @ling, with depth 0" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:ling).should be_new_record
        assigns(:ling).depth.should == 0
      end

      it "should assign 0 to @depth" do
        get :new, :group_id => groups(:inclusive).id
        assigns(:depth).should == 0
      end
    end
  end

  describe "set_values" do
    describe "assigns" do
      it "the requested ling to @ling and its depth to @depth" do
        get :set_values, :group_id => groups(:inclusive).id, :id => lings(:level0)
        assigns(:ling).should == lings(:level0)
        assigns(:depth).should == lings(:level0).depth

        get :set_values, :group_id => groups(:inclusive).id, :id => lings(:level1)
        assigns(:ling).should == lings(:level1)
        assigns(:depth).should == lings(:level1).depth
      end

      it "categories of the same depth as the ling to @categories" do
        get :set_values, :group_id => groups(:inclusive).id, :id => lings(:level0)
        assigns(:categories).should include categories(:inclusive0)
        assigns(:categories).should_not include categories(:inclusive1)

        get :set_values, :group_id => groups(:inclusive).id, :id => lings(:level1)
        assigns(:categories).should_not include categories(:inclusive0)
        assigns(:categories).should include categories(:inclusive1)
      end

      it "pre-existing LingsProperties for the ling to @preexisting_values" do
        get :set_values, :group_id => groups(:inclusive).id, :id => lings(:level0)
        assigns(:preexisting_values).should include lings_properties(:level0)
      end
    end
  end

  describe "submit_values" do
    it "assigns the requested ling to @ling" do
      post :submit_values, :group_id => groups(:inclusive).id, :id => lings(:level0)
      assigns(:ling).should == lings(:level0)
    end

    it "creates lings_properties for the ling and any submitted property values" do
      ling = lings(:level0)
      property = properties(:level0)
      group = ling.group
      value = "neverbeforeseen999"
      LingsProperty.find_by_ling_id_and_property_id_and_value(ling.id, property.id, value).should_not be_present
      post :submit_values, :group_id => group.id, :id => ling.id, :values => { ling.id.to_s => { "_new" => value } }
      LingsProperty.find_by_ling_id_and_property_id_and_value(ling.id, property.id, value).should be_present
    end

    it "destroys lings_properties for the ling if they are not included in the mass assignment" do
      lp = lings_properties(:level0)
      lp.should be_present
      deleted_id = lp.id
      ling = lp.ling
      group = lp.group
      post :submit_values, :group_id => group.id, :id => ling.id, :values => {}
      LingsProperty.find_by_id(deleted_id).should be_nil
    end

    it "does not do anything to lings_properties for the ling that were submitted when they already existed" do
      lp = lings_properties(:level0)
      lp.should be_present
      ling = lp.ling
      property = lp.property
      group = lp.group
      post :submit_values, :group_id => group.id, :id => ling.id, :values => {property.id.to_s => {lp.value => lp.value, :_new => ""}}
      lp.reload
      lp.should be_present
    end

    it "should redirect to set_values" do
      lp = lings_properties(:level0)
      post :submit_values, :group_id => lp.group.id, :id => lp.ling.id, :values => {lp.property.id.to_s => {lp.value => lp.value, :_new => ""}}
      response.should redirect_to set_values_group_ling_path(lp.group, lp.ling)
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested ling to @ling" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end

      it "the requested ling's depth to @depth" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:level1)
        assigns(:depth).should == lings(:level1).depth
      end

      it "available @depth-1 depth lings to @parents" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:level1)
        assigns(:parents).map{|ling| ling.depth}.uniq.should == [0]
      end

      it "an empty array to @parents if depth is < 0" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:level0)
        assigns(:parents).should == []
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created ling to @ling" do
        lambda {
          post :create, :group_id => groups(:inclusive).id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}
          assigns(:ling).should_not be_new_record
          assigns(:ling).should be_valid
          assigns(:ling).name.should == 'Javanese'
        }.should change(Ling, :count).by(1)
      end

      it "redirects to the created ling" do
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}
        response.should redirect_to(group_ling_url(assigns(:group), assigns(:ling)))
      end

      it "should set creator to be the currently logged in user" do
        user = Factory(:user)
        Membership.create(:member => user, :group => groups(:inclusive), :level => "admin")
        sign_in user
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => 'Javanese', 'depth' => '0', 'parent_id' => nil}
        assigns(:ling).creator.should == user
      end
    end

    describe "with invalid params" do
      it "does not save a new ling" do
        lambda {
          post :create, :group_id => groups(:inclusive).id, :ling => {'name' => '', 'depth' => nil}
          assigns(:ling).should_not be_valid
        }.should change(Ling, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => ''}
        response.should be_success
        response.should render_template("new")
      end

      describe "assigns" do
        before do
          post :create, :group_id => groups(:inclusive).id, :ling => {'name' => '', :depth => 1}
        end

        it "the requested ling's depth to @depth" do
          assigns(:depth).should == 1
        end

        it "available @depth-1 depth lings to @parents" do
          assigns(:parents).map{|ling| ling.depth}.uniq.should == [0]
        end
      end
    end
  end

  describe "update" do
    describe "with valid params" do
      it "calls update with the passed params on the requested ling" do
        ling = lings(:english)
        ling.should_receive(:update_attributes).with({'name' => 'eengleesh'}).and_return(true)
        Ling.should_receive(:find).with(ling.id).and_return(ling)

        put :update, :group_id => groups(:inclusive).id, :id => ling.id, :ling => {'name' => 'eengleesh'}
      end

      it "assigns the requested ling as @ling" do
        put :update, :group_id => groups(:inclusive).id, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end

      it "redirects to the ling" do
        put :update, :group_id => groups(:inclusive).id, :id => lings(:english)
        response.should redirect_to(group_ling_url(assigns(:group), lings(:english)))
      end
    end

    describe "with invalid params" do
      before do
        put :update, :group_id => groups(:inclusive).id, :id => lings(:level1), :ling => {'name' => ''}
      end

      it "assigns the ling as @ling" do
        assigns(:ling).should == lings(:level1)
      end

      it "assigns the requested ling's depth to @depth" do
        assigns(:depth).should == 1
      end

      it "assigns available @depth-1 depth lings to @parents" do
        assigns(:parents).map{|ling| ling.depth}.uniq.should == [0]
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end

  end

  describe "destroy" do
    it "calls destroy on the requested ling" do
      ling = lings(:english)
      ling.should_receive(:destroy).and_return(true)
      Ling.should_receive(:find).with(ling.id).and_return(ling)

      delete :destroy, :group_id => groups(:inclusive).id, :id => ling.id
    end

    it "assigns the deleted ling's depth to @depth" do
      delete :destroy, :group_id => groups(:inclusive).id, :id => lings(:level1)
      assigns(:depth).should == 1
    end

    it "redirects to the lings list for the appropriate depth" do
      delete :destroy, :group_id => groups(:inclusive).id, :id => lings(:level1)
      response.should redirect_to(group_lings_depth_url(assigns(:group), assigns(:depth)))
    end
  end
end
