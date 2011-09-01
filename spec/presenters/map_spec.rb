require "spec_helper"

describe Map do

  describe "center" do
    it "should return 0,0" do

      Map.new.center.should == [0,0]
    end
  end
end