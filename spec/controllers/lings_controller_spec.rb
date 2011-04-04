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
      it "@lings should be an array of subarrays ordered by ling depth" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:lings)[0].should include lings(:level0)
        assigns(:lings)[1].should include lings(:level1)
      end

      it "@lings should be an array with current_group.depth_maximum + 1 member subarrays" do
        get :index, :group_id => groups(:inclusive).id
        assigns(:lings).size.should == groups(:inclusive).depth_maximum + 1
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
  end

  describe "new" do
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

      it "should assign lings of @depth-1 depth to @lings" do
        get :new, :group_id => groups(:inclusive).id, :depth => 1
        assigns(:lings).map{|ling| ling.depth}.uniq.should == [0]
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

  describe "edit" do
    describe "assigns" do
      it "the requested ling to @ling" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end

      it "available depth 0 lings to @lings" do
        get :edit, :group_id => groups(:inclusive).id, :id => lings(:english)
        assigns(:lings).map{|ling| ling.depth}.uniq.should == [0]
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
        Membership.create(:user => user, :group => groups(:inclusive), :level => "admin")
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


      it "assigns depth 0 lings as @lings" do
        post :create, :group_id => groups(:inclusive).id, :ling => {'name' => '', 'depth' => nil}
        assigns(:lings).should include(lings(:level0))
      end

      it "re-renders the 'new' template" do
        post :create, :group_id => groups(:inclusive).id, :ling => {}
        response.should be_success
        response.should render_template("new")
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
        put :update, :group_id => groups(:inclusive).id, :id => lings(:english), :ling => {'name' => ''}
      end

      it "assigns the ling as @ling" do
        assigns(:ling).should == lings(:english)
      end

      it "assigns depth 0 lings as @lings" do
        assigns(:lings).should include(lings(:level0))
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

    it "redirects to the lings list" do
      delete :destroy, :group_id => groups(:inclusive).id, :id => lings(:english)
      response.should redirect_to(group_lings_url(assigns(:group)))
    end
  end
end
