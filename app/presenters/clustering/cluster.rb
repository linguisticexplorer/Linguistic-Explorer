module Accessors
  class Cluster

    attr_reader :left, :right, :name, :size
    attr_accessor :distance

    def initialize(c1, c2=nil)
      raise ArgumentError.new("A Cluster must have at least 1 point, given 0") unless c1.clustering_type?
      @left = c1
      @right = c2
      @name = c2 ? "#{c1.name}-#{c2.name}" : "#{c1.name}"
      @size = (c1.is_a? Point) ? 1 : c2 ? c1.size + c2.size : c1.size

      @distance = 0.1
    end

    def distance=(value)
      @distance = value==0 ? 0.1 : value
    end

    def key
      return @left.key if @left.is_a? Cluster
      @left.name.to_sym
    end

    def name
      @name =~ /\,/ ? @name.gsub(/,/, "-") : @name
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
      "(#{@left.to_newick}, #{@right.to_newick}):#{@distance}"
    end

  end
end