require "spec_helper"

describe GroupsController do
  describe "group level routing" do
    it "recognizes and generates #index" do
      { :get => "/groups" }.should route_to(:controller => "groups", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/groups/new" }.should route_to(:controller => "groups", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/groups/1" }.should route_to(:controller => "groups", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/groups/1/edit" }.should route_to(:controller => "groups", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/groups" }.should route_to(:controller => "groups", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/groups/1" }.should route_to(:controller => "groups", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/groups/1" }.should route_to(:controller => "groups", :action => "destroy", :id => "1")
    end
  end

  describe 'nested routes for' do
    nested_resources = ["lings", "properties", "lings_properties", "examples", "categories", "memberships", "examples_lings_properties"]
    nested_resources.each do |resource|
      describe resource do
        it "recognizes and generates #index" do
          { :get => "groups/1/#{resource}" }.should route_to(:controller => resource, :action => "index", :group_id => "1")
        end

        it "recognizes and generates #new" do
          { :get => "groups/1/#{resource}/new" }.should route_to(:controller => resource, :action => "new", :group_id => "1")
        end

        it "recognizes and generates #show" do
          { :get => "groups/1/#{resource}/1" }.should route_to(:controller => resource, :action => "show", :id => "1", :group_id => "1")
        end

        it "recognizes and generates #edit" do
          { :get => "groups/1/#{resource}/1/edit" }.should route_to(:controller => resource, :action => "edit", :id => "1", :group_id => "1")
        end

        it "recognizes and generates #create" do
          { :post => "groups/1/#{resource}" }.should route_to(:controller => resource, :action => "create", :group_id => "1")
        end

        it "recognizes and generates #update" do
          { :put => "groups/1/#{resource}/1" }.should route_to(:controller => resource, :action => "update", :id => "1", :group_id => "1")
        end

        it "recognizes and generates #destroy" do
          { :delete => "groups/1/#{resource}/1" }.should route_to(:controller => resource, :action => "destroy", :id => "1", :group_id => "1")
        end
      end
    end
  end
end
