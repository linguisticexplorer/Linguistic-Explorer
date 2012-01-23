module Linkages

  def select_linkage_strategy(linkage)
    if linkages_methods.include? linkage
      linkage
    else
      :avg
    end
  end

  def no_linkage(c1, c2, ci)
    dynamic_method(@distance_strategy).call(ci, c1)
  end

  def avg(cluster, cluster_i)
    c1 = cluster.size > 1 ? cluster.left.key : cluster.key
    c2 = cluster.size > 1 ? cluster.right.key : cluster.key
    ci = cluster_i.key
    left_size = cluster.left.size
    right_size = cluster.size > 1 ? cluster.right.size : 1
    (@dists[c1][ci] * left_size + @dists[c2][ci] * right_size) / (left_size + right_size)
  end

  def complete(cluster, cluster_i)
    c1 = cluster.left.key
    c2 = cluster.right.key
    ci = cluster_i.key
    @dists[c1][ci] < @dists[c2][ci] ? @dists[c2][ci] : @dists[c1][ci]
  end

  def single(cluster, cluster_i)
    c1 = cluster.left.key
    c2 = cluster.right.key
    ci = cluster_i.key
    @dists[c1][ci] > @dists[c2][ci] ? @dists[c2][ci] : @dists[c1][ci]
  end

  def linkages_methods
    [:avg, :single, :complete, :no_linkage]
  end
end
