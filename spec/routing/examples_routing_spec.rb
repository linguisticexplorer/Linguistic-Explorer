require "spec_helper"

describe ExamplesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/examples" }.should route_to(:controller => "examples", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/examples/new" }.should route_to(:controller => "examples", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/examples/1" }.should route_to(:controller => "examples", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/examples/1/edit" }.should route_to(:controller => "examples", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/examples" }.should route_to(:controller => "examples", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/examples/1" }.should route_to(:controller => "examples", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/examples/1" }.should route_to(:controller => "examples", :action => "destroy", :id => "1")
    end
  end
end
