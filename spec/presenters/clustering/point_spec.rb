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

      it "should be equal to another Point with same name and coords" do
        @point.should == Point.new("one", [0,0])
        @point.should.eql? Point.new("one", [0,0])
      end

      it "should be different to another Point with same coords but different name" do
        @point.should_not == Point.new("two", [0,0])
        @point.should_not.eql? Point.new("two", [0,0])
      end

      it "should be different to another Point with different name and coords" do
        @point.should_not == Point.new("two", [1,0])
        @point.should_not.eql? Point.new("two", [1,0])
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