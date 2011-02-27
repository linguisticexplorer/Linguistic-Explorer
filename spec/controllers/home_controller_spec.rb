require 'spec_helper'

describe HomeController do
  it "assigns all groups to @groups" do
    get :index
    assigns(:groups).size.should == Group.all.size
  end
end
