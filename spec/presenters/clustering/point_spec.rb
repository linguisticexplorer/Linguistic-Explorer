require "spec_helper"
module Accessors
  describe Point do

    describe "create a point" do
      before(:each) do
        @point = Point.new("one", [0,0])
      end

      it "should return the 'one' as name" do
        expect(@point.name).to eq 'one'
      end

      it "should return (0,0) as coords of the point" do
        expect(@point.coords).to eq [0,0]
      end

      it "should be equal to another Point with same name and coords" do
        expect(@point).to eq Point.new("one", [0,0])
        expect(@point).to eq Point.new("one", [0,0])
      end

      it "should be different to another Point with same coords but different name" do
        expect(@point).not_to eq Point.new("two", [0,0])
        expect(@point).not_to eq Point.new("two", [0,0])
      end

      it "should be different to another Point with different name and coords" do
        expect(@point).not_to eq Point.new("two", [1,0])
        expect(@point).not_to eq Point.new("two", [1,0])
      end
    end

    describe "create a point and its name include a comma" do
      before(:each) do
        @point = Point.new("Bajau, West Coast", [0,0])
      end

      it "should return the comma replaced by minus character" do
        expect(@point.name).to eq 'Bajau- West Coast'
      end
    end
  end
end