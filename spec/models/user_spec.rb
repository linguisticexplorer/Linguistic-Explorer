require 'spec_helper'

describe User do
  describe "one-liners" do
    it_should_validate_presence_of :name, :email, :access_level
#    it_should_validate_uniqueness_of :email #removed for devise-alternative set up email. best you can do is probably presence

    it_should_have_many :group_memberships, :groups
  end

  describe "createable with combinations" do
    it "should allow sane looking names and emails and access_level" do
      should_be_createable :with => { :name => "FIXME", :email => "FIXME@FiX.com", :access_level => "user" }
    end
  end
end
