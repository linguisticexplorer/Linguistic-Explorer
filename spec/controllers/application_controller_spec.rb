require 'spec_helper'

class UnmodifiedAppController < ApplicationController
  def generic_action
    render :nothing => true
  end
end

describe UnmodifiedAppController do
  before do
    LinguisticExplorer::Application.routes.draw do
      root :to => 'home#index'
      devise_for :user
      match 'unmodified_app/generic_action' => 'unmodified_app#generic_action'
    end
    sign_out :user
  end

  it "should not allow unauthorized user on any action" do
    get :generic_action
    response.should redirect_to(new_user_session_path)
  end

  it "should allow authorized users to use any action" do
    sign_in(Factory(:user))
    get :generic_action
    response.should_not redirect_to(new_user_session_path)
  end

  after do
    Rails.application.reload_routes!
  end
end

class OverriddenSubclassController < ApplicationController
#  skip_before_filter :authenticate_user!, :only => [:skipped_action]
  def skipped_action
    render :nothing => true
  end
end

describe OverriddenSubclassController do
  it "should allow unauthorized user on skip_before_filter'd actions" do
    LinguisticExplorer::Application.routes.draw do
      root :to => 'home#index'
      devise_for :user
      match 'overridden_subclass/skipped_action' => 'overridden_subclass#skipped_action'
    end

    sign_out :user
    get :skipped_action
    response.should_not redirect_to(root_url)

    Rails.application.reload_routes!
  end
end
