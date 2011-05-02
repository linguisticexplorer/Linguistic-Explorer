require 'spec_helper'

class ExtendingController < GroupDataController
  DATA_MODEL_NAME = :ling

  def index
    render :nothing => true
  end

  def data_test
    @ling = Ling.find(params[:id])
    render :nothing => true
  end
end

describe ExtendingController do
  before do
    LinguisticExplorer::Application.routes.draw do
      root :to => 'home#index'
      devise_for :user
      match 'extending/index' => 'extending#index'
      match 'extending/data_test/#id' => 'extending#data_test'
    end
    sign_out :user
  end

  it "should preload group on every action by default" do
    get :index, :group_id => groups(:inclusive).id
    response.should be_success
    assigns(:group).should == groups(:inclusive)
  end

  describe "ensure_not_misgrouped" do
    it "should not be called on index" do
      @controller.should_not_receive(:ensure_not_misgrouped)
      get :index
    end

    it "should raise an error if called in a controller non-index method with klass::DATA_CLASS of nil" do
      lambda do
        @controller.stub(::DATA_CLASS).and_return(nil)
        get :data_test, :group_id => @group.id, :id => @data.id
      end.should raise_error
    end

    it "should be called on other actions by default" do
      Ling.stub(:find)
      @controller.should_receive(:ensure_not_misgrouped)
      get :data_test, :id => nil
    end

    it "should send any request with misgrouped data to the home page" do
      @group = groups(:inclusive)
      @ling = lings(:exclusive0)
      @group.id.should_not == @ling.group.id
      get :data_test, :group_id => @group.id, :id => @ling.id #TODO: group_id appears here in an undocumented(by tests) way
      response.should redirect_to root_url
    end

    it "should add an alert to a request with misgrouped data" do
      @group = groups(:inclusive)
      @ling = lings(:exclusive0)
      @group.id.should_not == @ling.group.id
      get :data_test, :group_id => @group.id, :id => @ling.id #TODO: group_id appears here in an undocumented(by tests) way
      response.request.flash[:alert].should include("misgrouped")
    end
  end

  after do
    Rails.application.reload_routes!
  end
end

