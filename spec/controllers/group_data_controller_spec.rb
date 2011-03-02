require 'spec_helper'

class UnmodifiedGroupDataController < GroupDataController
  def index
    render :nothing => true
  end
end

describe UnmodifiedGroupDataController do
  before do
    LinguisticExplorer::Application.routes.draw do
      root :to => 'home#index'
      devise_for :user
      match 'unmodified_group_data/index' => 'unmodified_group_data#index'
    end
    sign_out :user
  end

  it "should preload group on every action by default" do
    get :index, :group_id => groups(:inclusive).id
    response.should be_success
    session[:group].should == groups(:inclusive)
  end

  after do
    Rails.application.reload_routes!
  end
end

class ModifiedGroupDataController < GroupDataController
  skip_before_filter :load_group_from_params
  def index
    render :nothing => true
  end
end

describe ModifiedGroupDataController do
  before do
    LinguisticExplorer::Application.routes.draw do
      root :to => 'home#index'
      devise_for :user
      match 'modified_group_data/index' => 'modified_group_data#index'
    end
    sign_out :user
  end

  it "should allow skip_before_filter to skip group preloading" do
    get :index
    response.should be_success
    session[:group].should be_nil
  end

  after do
    Rails.application.reload_routes!
  end
end
