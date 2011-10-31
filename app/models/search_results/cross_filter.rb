module SearchResults

  class CrossFilter < Filter

    def depth_0_vals
      #TODO: put LingsProps here
      @depth_0_vals ||= filter_vals(Depth::PARENT)
    end

    def depth_1_vals
      #TODO: put Lings here
      @depth_1_vals ||= filter_vals(Depth::CHILD)
    end

    private

    def filter_vals(depth)
      category_ids_at_depth = @query.category_ids_by_cross_grouping_and_depth(:property_set, depth)
      vals_at_depth         = @filter.vals_at(depth)

      if category_ids_at_depth.any?
        select_vals_by_cross(vals_at_depth, category_ids_at_depth)
      end
      vals_at_depth


    end

    def select_vals_by_cross(vals, category_ids)
      category_ids.collect do |category_id|
        required = selection_by_category_id(category_id)
        next if required.empty?
        collect_cross_from_vals(vals, required)
      end.flatten.compact
    end

    def collect_cross_from_vals(vals, associated)
      prop_values = [].tap do |p|
        associated.each do |prop_id|
          p << property_values_by_vals(vals, prop_id.to_i)
        end
      end
      cross_search_by_vals(vals, prop_values)
    end

    def cross_search_by_vals(vals, prop_values)
      properties_choosen_are_in_valid_range?(prop_values)

      first_prop = prop_values.first
      rest_props = prop_values.drop(1)

      combinations = first_prop.product(*rest_props)

      {}.tap do |hash|
        combinations.map do |c|
          hash[c] = ling_ids_with_combination(vals, c)
        end
      end
    end

    def properties_choosen_are_in_valid_range?(properties)
      # Raise an Exception if there are less properties than required
      raise Exceptions::ResultAtLeastTwoForCrossError if properties.size < 2
      # Avoid Cartesian Product with too many properties
      raise Exceptions::ResultTooManyForCrossError if properties.size > Search::RESULTS_CROSS_THRESHOLD
    end

    def property_values_by_vals(vals, prop_id)
      # return an an array for each prop_id with all possible values found in vals
      vals_by_property_id(vals)[prop_id.to_i].map(&:property_value).uniq
    end

    def ling_ids_with_combination(vals, combination)
      ling_ids = vals_by_ling_id(vals)

      ling_ids.select do |ling|
        combination.map(&:to_s).all? { |value| ling_with_combination?(ling_ids[ling], value) }
      end.keys
    end

    def vals_by_property_id(vals)
      vals.group_by { |v| v.property_id }
    end

    def vals_by_ling_id(vals)
      vals.group_by { |v| v.ling_id }
    end

    def selection_by_category_id(category_id)
      @query.selected_property_ids(category_id)
    end

    def ling_with_combination?(ling_props, value)
      ling_props.select { |lp| lp.property_value == value}.any?
    end
  end

end