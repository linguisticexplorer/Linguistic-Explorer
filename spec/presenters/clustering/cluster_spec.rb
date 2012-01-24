require "spec_helper"
module Accessors
  describe Cluster do

    describe "create a point" do
      before(:each) do
        left = Point.new("one", [0,0])
        right = Point.new("two", [1,1])
        @cluster = Cluster.new(left, right)
      end

      it "should return the 'one-two' as name" do
        @cluster.name.should == 'one-two'
      end

      it "should return (0,0) as coords of the left point" do
        @cluster.left.coords.should == [0,0]
      end

      it "should return (1,1) as coords of the right point" do
        @cluster.right.coords.should == [1,1]
      end
    end

    describe "create a point and its name include a comma" do
      before(:each) do
        left = Point.new("Bajau, West Coast", [0,0])
        right = Point.new("two", [1,1])
        @cluster = Cluster.new(left, right)
      end

      it "should return the comma replaced by minus character" do
        @cluster.name.should == 'Bajau- West Coast-two'
      end
    end
  end
end