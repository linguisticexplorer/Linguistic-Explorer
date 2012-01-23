module Accessors

  class Point

    attr_reader :name, :coords

    def initialize(name, coords)
      @coords = coords
      @name = name
    end

    def to_s
      "{\"name\": \"#{@name}\" ,\"coords\": \"#{@coords.inspect}\" }"
    end

    def clustering_type?
      true
    end

    def zip(point)
      @coords.zip point.coords
    end

    def ==(point)
      same = true
      return same if @name == point.name
      point.coords.each_index do |i|
        same &= @coords[i] == point.coords[i]
      end
      return same
    end

    def eql?(point)
      self==point
    end

    def size
      @coords.size
    end

  end
end

