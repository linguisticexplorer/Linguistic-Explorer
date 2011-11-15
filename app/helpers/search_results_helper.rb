module SearchResultsHelper
  include ActionView
  include SearchColumns
  include SearchCrossResultsHelper
  include SearchCompareResultsHelper

  def link_to_ling(ling)
    "<a href='/groups/#{current_group.to_param}/lings/#{ling.to_param}'>#{h(ling.name)}</a>".html_safe
  end

  def link_to_property(property)
    "<a href='/groups/#{current_group.to_param}/properties/#{property.to_param}'>#{h(property.name)}</a>".html_safe
  end

  def row_methods
    @row_methods ||= {
      :ling_0           => lambda { |v| link_to_ling(v.ling) },
      :ling_1           => lambda { |v| link_to_ling(v.ling) },
      :property_0       => lambda { |v| link_to_property(v.property) },
      :property_1       => lambda { |v| link_to_property(v.property) },
      :value_0          => lambda { |v| v.value  },
      :value_1          => lambda { |v| v.value  },
      :example_0        => lambda { |v| v.examples.map(&:name).join(", ") },
      :example_1        => lambda { |v| v.examples.map(&:name).join(", ") },
      # Cross Search
      :cross_property   => lambda { |v| link_to_property(v.property) },
      :cross_value      => lambda { |v| v.value },
      :count            => lambda { |parent, v| link_to_cross_lings(parent, v) },
      # Compare Search
      :compare_property => lambda { |v| link_to_property(v.property) },
      :common_values    => lambda { |v| v.value },
      :ling_value       => lambda { |v| v.value }
    }
  end

  def search_result_attributes(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_result row"
      attrs["data-parent-value"] = entry.parent.id
      attrs["data-child-value"]  = entry.child.id unless entry.child.nil?
    end
  end

  def display_save_search_form?(search)
    user_signed_in? && search.new_record? && search.default? && !current_user.reached_max_search_limit?(current_group)
  end

end
