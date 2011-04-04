require "spec_helper"

describe LingsController do
  describe "custom depth action routing" do
    it "recognizes and generates lings/#depth/0" do
      g_id = groups(:inclusive).id
      assert_generates "/groups/#{g_id}/lings/depth/0", { :controller => "lings", :action => "depth", :group_id => g_id, :depth => "0" }
    end

    it "recognizes and generates lings/#depth/1" do
      g_id = groups(:inclusive).id
      assert_generates "/groups/#{g_id}/lings/depth/1", { :controller => "lings", :action => "depth", :group_id => g_id, :depth => "1" }
    end
  end
end
