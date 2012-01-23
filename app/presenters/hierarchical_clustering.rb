require 'clustering/linkages.rb'
require 'clustering/distances.rb'
require 'clustering/point.rb'
require 'clustering/cluster.rb'

class HierarchicalClustering
  include Linkages
  include Distances
  include Accessors
  ## Porting in Ruby of clusterfck.js clustering agglomerative algorithm
  ## https://github.com/harthur/clusterfck
  #Copyright (c) 2011 Heather Arthur <fayearthur@gmail.com>
  #
  #Permission is hereby granted, free of charge, to any person obtaining
  #a copy of this software and associated documentation files (the
  #"Software"), to deal in the Software without restriction, including
  #without limitation the rights to use, copy, modify, merge, publish,
  #distribute, sublicense, and/or sell copies of the Software, and to
  #permit persons to whom the Software is furnished to do so, subject to
  #the following conditions:
  #
  #The above copyright notice and this permission notice shall be
  #included in all copies or substantial portions of the Software.
  #
  #THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  #EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  #MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  #NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  #LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  #OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  #WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  #include clustering
  INFINITY = (+1.0 / 0)

  def initialize(hash_data, format = nil, threshold = nil)
    @points = create_points_from hash_data
    @format_strategy = select_format_strategy format
    @threshold = threshold || INFINITY
  end

  def format_methods
    [:newick]
  end

  def cluster(distance = :euclidean, linkage = :avg)
    @distance_strategy = select_distance_strategy distance
    @linkage_strategy =  select_linkage_strategy linkage

    @clusters = {} # Clusters list
    @dists = {} # distance matrix
    @mins = {} # closest point matrix

    # Create clusters
    @points.each do |point|
      cluster = Cluster.new(point)
      @clusters[cluster.key] = cluster
      @dists[cluster.key] = {}
      @mins[cluster.key] = @clusters.keys.first
    end

    # Populate distance matrix
    populate_distance_matrix

    while @clusters.size > 1
      key_closest_cluster = @clusters.keys.first
      min_distance = INFINITY

      # Find two closest clusters from cached mins
      @clusters.keys.each do |key|
        dist = @dists[key][@mins[key]]
        if dist < min_distance
          key_closest_cluster = key
          min_distance = dist
        end
      end

      break if min_distance >= @threshold

      # Create a cluster
      merged_cluster = merge_cluster(key_closest_cluster, min_distance)

      # Update distances with the new cluster using selected linkage method
      find_cluster_center_by_linkage(merged_cluster)

      # Update closest cluster for each
      update_mins(merged_cluster)
    end
    self
  end

  def to_s
    return to_newick if @format_strategy==:newick
    return "{}" if @clusters.empty?
    @clusters.values.first.to_s
  end

  private

  def to_newick
    return "()" if @clusters.empty?
    @clusters.values.first.to_newick
  end

  def populate_distance_matrix
    @clusters.each do |key_i, cluster_i|
      @clusters.each do |key_j, cluster_j|
        dist = (key_i) == (key_j) ? INFINITY :
            dynamic_method(@distance_strategy).call(cluster_i.left, cluster_j.left)
        @dists[key_i][key_j] = dist
        @dists[key_j][key_i] = dist

        if dist < @dists[key_i][@mins[key_i]]
          @mins[key_i] = key_j
        end
      end
    end
  end

  def merge_cluster(key_closest_cluster, min_distance)
    left_child = @clusters[key_closest_cluster]
    right_child = @clusters[@mins[key_closest_cluster]]
    merged_cluster = Cluster.new(left_child, right_child)
    left_child.distance = min_distance
    right_child.distance = min_distance

    # Delete merged cluster on the right from the list
    @clusters.reject! { |k, v| k==right_child.key }

    # Insert the cluster in the list, using the most left cluster's key
    @clusters[merged_cluster.key] = merged_cluster
    merged_cluster
  end

  def create_points_from(hash_data)
    [].tap do |points|
      hash_data.each do |name, coords|
        points << Point.new(name, coords)
      end
    end
  end

  def new_neighbour_for_ling?(ling)
    @mins[ling] && @dists[ling][@mins[ling]]
  end

  def dynamic_method(method_name)
    self.method(method_name)
  end

  def update_mins(merged_cluster)
    @clusters.keys.each do |key_i|
      if is_the_closest?(merged_cluster, key_i)
        min_key = key_i
        @clusters.keys.each do |key_j|
          min_key = key_j if is_there_a_closer_one?(key_i, key_j, min_key)
        end
        @mins[key_i] = min_key
      end
    end
  end

  def find_cluster_center_by_linkage(merged_cluster)
    @clusters.each do |key, cluster|
      dist = if merged_cluster.key == key
               INFINITY
             elsif @linkage_strategy
               dynamic_method(@linkage_strategy).call(merged_cluster, cluster)
             else
               dynamic_method(@distance_strategy).call(merged_cluster.left.left, cluster.left)
             end
      @dists[merged_cluster.key][key] = @dists[key][merged_cluster.key] = dist
    end
  end

  def is_the_closest?(cluster, key_i)
    left_key = cluster.left.key
    right_key = cluster.right.key
    @mins[key_i] == left_key || @mins[key_i] == right_key
  end

  def is_there_a_closer_one?(key_i, key_j, min_key)
    @dists[key_i][key_j] < @dists[key_i][min_key]
  end

  def select_format_strategy(format)
    if format_methods.include? format
      format
    else
      :to_s
    end
  end

end
