require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe "site admins" do
    it "should be able to manage every object" do
      ability = Ability.new(Factory(:user, :access_level => "admin"))
      [Ling, Property, Category, LingsProperty, Example, Group, GroupMembership].each do |klass|
        ability.should be_able_to(:manage, klass )
      end
    end
  end

  describe "visitors" do
    it "should be able to register as a new user" do

    end

    it "should not be able to see users, private groups and their data" do

    end

    it "should be able to view public groups and their data" do

    end
  end

  describe "logged in users" do
    it "should be able to manage themselves" do

    end

    it "should not be able to manage other users" do

    end
  end

  describe "group admins" do
    it "should be able to manage their group and all data within it" do

    end
  end

  describe "group members" do
    it "should be able to manage examples, LPVs, ELPVs in their groups" do

    end

    it "should be able to view the group and its lings, properties, categories, and memberships" do

    end

    it "should be able to delete their own memberships" do

    end
  end
end
