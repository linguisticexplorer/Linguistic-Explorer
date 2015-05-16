require "spec_helper"

describe HomeController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "/" }).to route_to(:controller => "home", :action => "index")
    end
  end
end
