require 'rails_helper'

describe HomeController do
  it "assigns accessible groups @groups if signed in" do
    allow(@controller).to receive_message_chain(:user_signed_in?).and_return(true)
    @group = groups(:inclusive)
    expect(Group).to receive(:accessible_by).and_return ( [ @group ] )
    get :index
    expect(assigns(:groups)).to include @group
  end

  it "assigns public groups to @groups if not signed in" do
    allow(@controller).to receive_message_chain(:user_signed_in?).and_return(false)
    @group = groups(:inclusive)
    expect(Group).to receive(:public).and_return ( [ @group ] )
    get :index
    expect(assigns(:groups)).to include @group
  end
end
