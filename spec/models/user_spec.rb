require 'spec_helper'

describe User do
  describe "one-liners" do
    it_should_validate_presence_of :name, :email, :access_level
    it_should_have_many :group_memberships, :groups
  end

  describe "createable with combinations" do
    it "should allow sane looking names and passwords, and require access_level and email after the fact" do
      u = User.new(:name => "FIXME", :password => "password")
      u.email = "FIXME@FiX.com"
      u.access_level = "user"
      u.save!
      u.should_not be_new_record
    end
  end
end
