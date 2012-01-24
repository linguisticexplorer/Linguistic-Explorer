  module SearchResults

    module SpecialSearchQueryAdapter
      def is_cross_search?
        category_ids_by_cross_grouping(:property_set).any?
      end

      def is_special_search?
        is_cross_search? || is_compare_search? || is_implication_search? || is_clustering?
      end

      def is_implication_search?
        is_both_implication_search? || is_antecedent_implication_search? ||
            is_consequent_implication_search? || is_double_implication_search?
      end

      def is_compare_search?
        depth_by_compare_grouping(:ling_set).any?
      end

      def is_both_implication_search?
        is_advanced_search? && advanced_set_impl=="both"
      end

      def is_antecedent_implication_search?
        is_advanced_search? && advanced_set_impl=="ante"
      end

      def is_consequent_implication_search?
        is_advanced_search? && advanced_set_impl=="cons"
      end

      def is_double_implication_search?
        is_advanced_search? && advanced_set_impl=="double"
      end

      def is_clustering?
        is_advanced_search? && advanced_set_clustering=~/hamming/
      end

      def is_javascript_enabled?
        is_advanced_search? && javascript_hidden_field==1
      end

      def javascript_hidden_field
        self[:javascript]
      end

      def advanced_set_impl
        self[:advanced_set]["impl"]
      end

      def advanced_set_clustering
        self[:advanced_set]["clustering"]
      end

      def is_advanced_search?
        self[:advanced_set].present?
      end

      def advanced_set(type)
        self[:advanced_set][type]
      end

      def depth_of_implication
        selected_depths ||= filter_depth_for_impl included_columns(true)
        return [0] if selected_depths.empty? && !has_depth?
        depths = []
        depths << 0 if selected_depths.include?(:depth_0)
        depths << 1 if selected_depths.include?(:depth_1)
        depths
      end

      def depth_of_cross_search
        if is_cross_search?
          category_ids_by_cross_depth(0).any? ? Depth::PARENT : Depth::CHILD
        end
      end

      def depth_of_compare_search
        if is_compare_search?
          depth_by_compare_grouping(:ling_set).first.to_i
        end
      end

      def category_ids_by_cross_depth(depth)
        group_prop_category_ids(depth).select { |c|
          category_ids_by_cross_grouping(:property_set).include?(c)
        }
      end

      def selected_ling_ids_to_compare(depth)
        lings[depth.to_s] || []
      end

      private

      def filter_depth_for_impl(columns_array)
        columns_array.select {|column| /depth/.match(column.to_s)}
      end

      def is_special_search_valid?
        if is_cross_search?
          validate_cross
        elsif is_compare_search?
          validate_compare
        end
      end

      def validate_cross
        sel_props = selected_properties_to_cross(depth_of_cross_search)
        # Raise an Exception if there are less properties than required
        raise Exceptions::ResultAtLeastTwoForCrossError if sel_props.size < 2 || properties.nil?
        # Avoid Cartesian Product with too many properties
        raise Exceptions::ResultTooManyForCrossError if sel_props.size > Search::RESULTS_CROSS_THRESHOLD
      end

      def validate_compare
        sel_lings = selected_ling_ids_to_compare(depth_of_compare_search)
        raise Exceptions::ResultAtLeastTwoForCompareError if sel_lings.size < 2 || lings.nil?
        raise Exceptions::ResultTooManyForCompareError if sel_lings.size > dynamic_threshold(10)
      end

      def dynamic_threshold(threshold)
        # Two Properties for too many lps
        lings_property_in_group_number > 100000 ? 2 : threshold
      end

      def category_ids_by_cross_grouping(grouping)
        # {"1"=>"all", "2"=>"any", "3"=>"cross"} --> [3]
        category_cross_pairs ||= [] if self[grouping].nil?
        category_cross_pairs ||= self[grouping].group_by { |k, v| v }["cross"] || []
        category_cross_pairs.map { |c| c.first }.map(&:to_i)
      end

      def depth_by_compare_grouping(grouping)
        # {"0"=>"compare"} --> [0]
        return [] if self[grouping].nil?
        self[grouping].select {|k,v| v=="compare"}.keys
      end
    end

  end