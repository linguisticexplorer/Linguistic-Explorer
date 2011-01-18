require 'spec_helper'

describe LingsController do
  fixtures :all

  describe "index" do
    describe "assigns" do
      it "@lings should contain every ling" do
        get :index
        assigns(:lings).should include lings(:english)
      end
    end
  end

  describe "show" do
    describe "assigns" do
      it "@ling should match the passed id" do
        get :show, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end
    end
  end

  describe "new" do
    describe "assigns" do
      it "a new ling to @ling" do
        get :new
        assigns(:ling).should be_new_record
      end
    end
  end

  describe "edit" do
    describe "assigns" do
      it "the requested ling to @ling" do
        get :edit, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end
    end
  end

  describe "create" do
    describe "with valid params" do
      it "assigns a newly created ling to @ling" do
        lambda {
          post :create, :ling => {'name' => 'Javanese'}
          assigns(:ling).should_not be_new_record
          assigns(:ling).should be_valid
          assigns(:ling).name.should == 'Javanese'
        }.should change(Ling, :count).by(1)
      end

      it "redirects to the created ling" do
        post :create, :ling => {'name' => 'Javanese'}
        response.should redirect_to(ling_url(assigns(:ling)))
      end
    end

    describe "with invalid params" do
      it "does not save a new ling" do
        lambda {
          post :create, :ling => {'name' => ''}
          assigns(:ling).should_not be_valid
        }.should change(Ling, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, :ling => {}
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

        put :update, :id => ling.id, :ling => {'name' => 'eengleesh'}
      end

      it "assigns the requested ling as @ling" do
        put :update, :id => lings(:english)
        assigns(:ling).should == lings(:english)
      end

      it "redirects to the ling" do
        put :update, :id => lings(:english)
        response.should redirect_to(ling_url(lings(:english)))
      end
    end

    describe "with invalid params" do
      before do
        put :update, :id => lings(:english), :ling => {'name' => ''}
      end

      it "assigns the ling as @ling" do
        assigns(:ling).should == lings(:english)
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

      delete :destroy, :id => ling.id
    end

    it "redirects to the lings list" do
      delete :destroy, :id => lings(:english)
      response.should redirect_to(lings_url)
    end
  end
end
