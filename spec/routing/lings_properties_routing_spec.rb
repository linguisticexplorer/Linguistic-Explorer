require "spec_helper"

describe LingsPropertiesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/lings_properties" }.should route_to(:controller => "lings_properties", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/lings_properties/new" }.should route_to(:controller => "lings_properties", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/lings_properties/1" }.should route_to(:controller => "lings_properties", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/lings_properties/1/edit" }.should route_to(:controller => "lings_properties", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/lings_properties" }.should route_to(:controller => "lings_properties", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/lings_properties/1" }.should route_to(:controller => "lings_properties", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/lings_properties/1" }.should route_to(:controller => "lings_properties", :action => "destroy", :id => "1")
    end
  end
end
