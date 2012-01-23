require "spec_helper"

describe HierarchicalClustering do

  describe "calculate a hierarchical cluster" do
    before(:each) do
      @clusterer = HierarchicalClustering.new({})
    end

    describe "with zero distance using different formulas: " do
      it "should return 0" do
        @clusterer.euclidean([0,0],[0,0]).should == 0
      end

      it "calculate zero distance with manhattan formula" do
        @clusterer.manhattan([0,0],[0,0]).should == 0
      end

      it "calculate zero distance with max formula" do
        @clusterer.max([0,0],[0,0]).should == 0
      end
    end

    describe "calculate distance between two points: " do
      it "should return 2 by euclidean formula" do
        @clusterer.euclidean([0,0],[0,2]).should == 2
      end

      it "should return 2 by manhattan formula" do
        @clusterer.manhattan([0,0],[0,2]).should == 2
      end

      it "should return 2 by max formula" do
        @clusterer.max([0,0],[0,2]).should == 2
      end
    end

    describe "calculate distance with null points: " do
      it "should raise an Error by euclidean formula" do
        expect { @clusterer.euclidean([0,0], nil) }.should raise_error(ArgumentError)
      end

      it "should raise an Error by manhattan formula" do
        expect { @clusterer.manhattan([0,0], nil) }.should raise_error(ArgumentError)
      end

      it "should raise an Error by max formula" do
        expect { @clusterer.max([0,0], nil) }.should raise_error(ArgumentError)
      end
    end

    describe "with no points:" do
      it "compute cluster with euclidean and average linkage" do
        @clusterer.cluster.to_s.should == "{}"
      end
    end

  end
  describe "calculate a hierarchical cluster" do
    before(:each) do
      @clusterer = HierarchicalClustering.new({"one" => [0,0]})
    end

    describe "with one point and average linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:euclidean).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:manhattan).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:max).to_s.should == expected_string
      end
    end

    describe "with one point and single linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:euclidean, :single).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:manhattan, :single).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:max, :single).to_s.should == expected_string
      end
    end

    describe "with one point and complete linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:euclidean, :complete).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:manhattan, :complete).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }"
        @clusterer.cluster(:max, :complete).to_s.should == expected_string
      end
    end
  end

  describe "calculate a hierarchical cluster by distances" do
    before(:each) do
      @clusterer = HierarchicalClustering.new({"one" => [0,0], "two" => [1,1]})
    end

    describe "with two point and average linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster.to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:manhattan).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:max).to_s.should == expected_string
      end
    end
    describe "with two point and single linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:euclidean, :single).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:manhattan, :single).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:max, :single).to_s.should == expected_string
      end
    end

    describe "with two point and complete linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:euclidean, :complete).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:manhattan, :complete).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }"
        @clusterer.cluster(:max, :complete).to_s.should == expected_string
      end

    end
  end

  describe "calculate a hierarchical cluster by linkages" do
    before(:each) do
      @clusterer = HierarchicalClustering.new({"one" => [0,0], "two" => [1,1], "three" => [0,2]})
    end

    describe "with more points with average linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:euclidean).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:manhattan).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:max).to_s.should == expected_string
      end
    end

    describe "with more points with single linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:euclidean, :single).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:manhattan, :single).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:max, :single).to_s.should == expected_string
      end
    end

    describe "with more points with complete linkage:" do
      it "compute cluster with euclidean distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:euclidean, :complete).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:manhattan, :complete).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2]\" }], \"size\": 3 }"
        @clusterer.cluster(:max, :complete).to_s.should == expected_string
      end
    end
  end



  describe "with more points with average linkage in a 5th dimensional spacein a 5th dimensional space:" do
    before(:each) do
      @clusterer = HierarchicalClustering.new({"one" => [0, 0, 0, 0, 0], "two" => [1,1,1,1,1], "three" => [0,2,2,2,2]})
    end
    it "compute cluster with euclidean distance" do
      expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0, 0, 0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1, 1, 1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2, 2, 2, 2]\" }], \"size\": 3 }"
      @clusterer.cluster(:euclidean).to_s.should == expected_string
    end

    it "compute cluster with manhattan distance" do
      expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0, 0, 0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1, 1, 1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2, 2, 2, 2]\" }], \"size\": 3 }"
      @clusterer.cluster(:manhattan).to_s.should == expected_string
    end

    it "compute cluster with max distance" do
      expected_string = "{ \"name\": \"one-two-three\", \"children\": [{ \"name\": \"one-two\", \"children\": [{\"name\": \"one\" ,\"coords\": \"[0, 0, 0, 0, 0]\" }, {\"name\": \"two\" ,\"coords\": \"[1, 1, 1, 1, 1]\" }], \"size\": 2 }, {\"name\": \"three\" ,\"coords\": \"[0, 2, 2, 2, 2]\" }], \"size\": 3 }"
      @clusterer.cluster(:max).to_s.should == expected_string
    end
  end

  describe "calculate a hierarchical cluster and output in Newick format in a 5th dimensional space" do


    describe "with more points with average linkage:" do

      before(:each) do
        @clusterer = HierarchicalClustering.new({"one" => [0, 0, 0, 0, 0], "two" => [1,1,1,1,1], "three" => [0,2,2,2,2]}, :newick)
      end
      it "compute cluster with euclidean distance" do
        expected_string = "((one:2.23606797749979, two:2.23606797749979), three:3.118033988749895)"
        @clusterer.cluster(:euclidean).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "((one:5, two:5), three:6)"
        @clusterer.cluster(:manhattan).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "((one:1, two:1), three:1)"
        @clusterer.cluster(:max).to_s.should == expected_string
      end
    end

    describe "with more points with average linkage:" do
      before(:each) do
        @clusterer = HierarchicalClustering.new({"one" => [0,0], "two" => [1,1], "three" => [0,2]}, :newick)
      end
      it "compute cluster with euclidean distance" do
        expected_string = "((one:1.4142135623730951, two:1.4142135623730951), three:1.7071067811865475)"
        @clusterer.cluster(:euclidean).to_s.should == expected_string
      end

      it "compute cluster with manhattan distance" do
        expected_string = "((one:2, two:2), three:2)"
        @clusterer.cluster(:manhattan).to_s.should == expected_string
      end

      it "compute cluster with max distance" do
        expected_string = "((one:1, two:1), three:1)"
        @clusterer.cluster(:max).to_s.should == expected_string
      end
    end
  end

end