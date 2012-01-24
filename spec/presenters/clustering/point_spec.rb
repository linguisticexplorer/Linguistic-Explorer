require "spec_helper"
module Accessors
  describe Point do

    describe "create a point" do
      before(:each) do
        @point = Point.new("one", [0,0])
      end

      it "should return the 'one' as name" do
        @point.name.should == 'one'
      end

      it "should return (0,0) as coords of the point" do
        @point.coords.should == [0,0]
      end
    end

    describe "create a point and its name include a comma" do
      before(:each) do
        @point = Point.new("Bajau, West Coast", [0,0])
      end

      it "should return the comma replaced by minus character" do
        @point.name.should == 'Bajau- West Coast'
      end
    end
  end
end