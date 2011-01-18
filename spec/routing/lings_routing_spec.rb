require "spec_helper"

describe LingsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/lings" }.should route_to(:controller => "lings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/lings/new" }.should route_to(:controller => "lings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/lings/1" }.should route_to(:controller => "lings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/lings/1/edit" }.should route_to(:controller => "lings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/lings" }.should route_to(:controller => "lings", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/lings/1" }.should route_to(:controller => "lings", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/lings/1" }.should route_to(:controller => "lings", :action => "destroy", :id => "1")
    end
  end
end
