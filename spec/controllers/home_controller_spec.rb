require 'spec_helper'

describe HomeController do
  it "assigns accessible groups @groups" do
    @group = groups(:inclusive)
    Group.should_receive(:accessible_by).and_return ( [ @group ] )
    get :index
    assigns(:groups).should include @group
  end
end
