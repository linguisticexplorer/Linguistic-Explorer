module Distances

  def select_distance_strategy(distance)
    if distances_methods.include? distance
      distance
    else
      :euclidean
    end
  end

  def max(p1, p2)
    points_pass_checks?(p1, p2)
    max = 0
    (p1.zip p2).each do |c1, c2|
      max = [max, (c2 - c1).abs].max
    end
    return max
  end

  def manhattan(p1, p2)
    points_pass_checks?(p1, p2)
    total = 0
    (p1.zip p2).each do |c1, c2|
      total = total + (c2 - c1).abs
    end
    return total
  end

  def points_pass_checks?(p1, p2)
    raise ArgumentError.new("This method must receive two points") unless p1 && p2
    raise ArgumentError.new("Two points passed have not the same number of coordinates") unless p1.size == p2.size
    return true
  end

  def euclidean(p1, p2)
    points_pass_checks?(p1, p2)
    total = 0
    (p1.zip p2).each do |c1, c2|
      total = total + (c1-c2)**2
    end
    return Math.sqrt(total)
  end

  def distances_methods
    [:euclidean, :manhattan, :max]
  end
end
