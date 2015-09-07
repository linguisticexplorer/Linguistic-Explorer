require 'spec_helper'

def sign_in_as_admin
  @user = FactoryGirl.create(:user, :access_level => 'admin')
  sign_in @user
end

def sign_in_as_group_admin
  @user = FactoryGirl.create(:user)
  Membership.create(:member => @user, :group => groups(:inclusive), :level => "admin")
  sign_in @user
end