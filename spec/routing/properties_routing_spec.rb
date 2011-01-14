require "spec_helper"

describe PropertiesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/properties" }.should route_to(:controller => "properties", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/properties/new" }.should route_to(:controller => "properties", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/properties/1" }.should route_to(:controller => "properties", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/properties/1/edit" }.should route_to(:controller => "properties", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/properties" }.should route_to(:controller => "properties", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/properties/1" }.should route_to(:controller => "properties", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/properties/1" }.should route_to(:controller => "properties", :action => "destroy", :id => "1")
    end

  end
end
