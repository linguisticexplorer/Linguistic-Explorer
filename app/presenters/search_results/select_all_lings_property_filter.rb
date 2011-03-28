module SearchResults

  class SelectAllFilter < Filter

    def initialize(filter, params)
      @filter   = filter
      @params   = params

      @depth_0_vals, @depth_1_vals = filter_by_all_selection_within_category
    end
    delegate  :group_prop_category_ids,
              :selected_lings_properties_by_depth,
              :selected_property_ids_by_depth, :to => :filter

    def grouping
      :property_set
    end

    def self.collect_all_from_vals(vals, associated_ids)
      # [vals] --> {1 => [val,val], 2 ==> [val, val] etc.}
      ling_id_groups = vals.group_by { |v| v.ling_id }

      # select depth vals whose ling_ids have all properties in category for all section
      vals.select do |v|
        associated_ids.all? { |id| ling_id_groups[v.ling_id].map(&:property_id).include?(id) }
      end
    end

    def filter_by_all_selection_within_category
      category_ids = params_for_all_to_category_ids

      if category_ids
        [filter_by_all_selection(Depth::PARENT), filter_by_all_selection(Depth::CHILD)]
      else
        [@filter.depth_0_vals, @filter.depth_1_vals]
      end
    end

    def filter_by_all_selection(depth)
      category_ids_at_depth = category_ids_at(depth)
      vals = @filter.send("depth_#{depth}_vals")

      if category_ids_at_depth.any?
        required = Property.ids.where(:category_id => category_ids_at_depth, :id => selected_property_ids_by_depth(depth))
        self.class.collect_all_from_vals(vals, required.map(&:id))
      else
        vals
      end
    end

    def category_ids_at(depth)
      # group_prop_category_ids defined in CategorizedParamsAdapter
      group_prop_category_ids(depth).select { |c| params_for_all_to_category_ids.include?(c) }
    end

    def params_for_all_to_category_ids(params)
      # {"1"=>"all", "2"=>"any"} --> [1]
      @params_for_all_to_category_ids ||= begin
        category_all_pairs = @params[grouping].group_by { |k,v| v }["all"] || []
        category_all_pairs.map { |c| c.first }.map(&:to_i)
      end
    end

  end

end