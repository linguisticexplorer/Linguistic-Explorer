module Accessors
  class Cluster

    attr_reader :left, :right, :name, :size
    attr_accessor :distance

    def initialize(c1, c2=nil)
      raise ArgumentError.new("A Cluster must have at least 1 point, given 0") unless c1.clustering_type?
      @left = c1
      @right = c2
      @name = c2 ? "#{c1.name}-#{c2.name}" : "#{c1.name}"
      if c1.is_a? Point
        @size = 1
      else
        @size = c2 ? c1.size + c2.size : c1.size
      end
      @distance = 0.1
    end

    def key
      if @left.is_a? Cluster
        return @left.key
      else
        @left.name.to_sym
      end
    end

    def to_s
      return @left.to_s if @size == 1
      "{ \"name\": \"#{@name}\", \"children\": [#{@left.to_s}, #{@right.to_s}], \"size\": #{@size} }"
    end

    def clustering_type?
      true
    end

    def to_newick
      return "#{@left.name}:#{@distance}" if @size == 1
      "(#{@left.to_newick}, #{@right.to_newick})"
    end

  end
end