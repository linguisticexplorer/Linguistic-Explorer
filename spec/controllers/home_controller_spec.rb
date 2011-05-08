require 'spec_helper'

describe HomeController do
  it "assigns accessible groups @groups if signed in" do
    @controller.stub!(:user_signed_in?).and_return(true)
    @group = groups(:inclusive)
    Group.should_receive(:accessible_by).and_return ( [ @group ] )
    get :index
    assigns(:groups).should include @group
  end

  it "assigns public groups to @groups if not signed in" do
    @controller.stub!(:user_signed_in?).and_return(false)
    @group = groups(:inclusive)
    Group.should_receive(:public).and_return ( [ @group ] )
    get :index
    assigns(:groups).should include @group
  end
end
