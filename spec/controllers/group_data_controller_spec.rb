require 'spec_helper'

class ExtendingController < GroupDataController
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

  after do
    Rails.application.reload_routes!
  end
end

