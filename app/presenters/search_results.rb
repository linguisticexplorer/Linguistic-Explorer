module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    LingsProperty.with_id(selected_lings_prop_ids).includes([{:ling => :parent}, :property])
  end

  private

  def parent
    Ling::PARENT
  end

  def child
    Ling::CHILD
  end

  def selected_lings_prop_ids
    depth_0_vals  = filter_depth_0_lings_prop_ids

    depth_1_vals  = filter_depth_1_lings_prop_ids

    depth_0_vals, depth_1_vals = filter_by_lings_prop_params(depth_0_vals, depth_1_vals)

    depth_0_vals, depth_1_vals = intersect_lings_prop_ids(depth_0_vals, depth_1_vals)

    depth_0_vals, depth_1_vals = filter_by_all_conditions(depth_0_vals, depth_1_vals, :property_group)

    depth_0_vals, depth_1_vals = filter_by_all_conditions(depth_0_vals, depth_1_vals, :lings_property_group)

    (depth_0_vals + depth_1_vals).map(&:id)
  end

  def ling_filter
    @ling_filter ||= LingFilter.new(@group, @params[:lings])
  end

  def prop_filter
    @prop_filter ||= PropertyFilter.new(@group, categorized_to_depth(@params[:properties]))
  end

  def filter_depth_0_lings_prop_ids
    LingsProperty.select_ids.where(:ling_id => ling_filter.ids(parent), :property_id => prop_filter.ids(parent))
  end

  def filter_depth_1_lings_prop_ids
    return [] unless ling_filter.ids(child).any?
    LingsProperty.select_ids.where(:ling_id => ling_filter.ids(child), :property_id => prop_filter.ids(child))
  end

  def intersect_lings_prop_ids(depth_0_vals, depth_1_vals)
    # Calling "to_a" because of bug in rails when calling empty?/any? on relation not yet loaded
    # Fixed at https://github.com/rails/rails/commit/015192560b7e81639430d7e46c410bf6a3cd9223

    if depth_1_vals.to_a.any?
      depth_1_vals  = ( LingsProperty.select_ids.with_id(depth_1_vals.map(&:id)).where(:property_id => prop_filter.ids(child)) & Ling.parent_ids.with_parent_id(depth_0_vals.map(&:ling_id).uniq))

      depth_0_vals  =   LingsProperty.select_ids.with_id(depth_0_vals.map(&:id)).with_ling_id(depth_1_vals.map(&:parent_id).uniq).where(:property_id => prop_filter.ids(parent))

    end

    [depth_0_vals, depth_1_vals]
  end

  def filter_by_lings_prop_params(depth_0_vals, depth_1_vals)
     if lings_prop_param_pairs(parent).any?
       depth_0_vals = LingsProperty.ids.where(lings_prop_param_conditions(parent) & {:id => depth_0_vals})
     end
     if lings_prop_param_pairs(child).any?
       depth_1_vals = LingsProperty.ids.where(lings_prop_param_conditions(child) & {:id => depth_1_vals})
     end
     [depth_0_vals, depth_1_vals]
  end

  def lings_prop_params
    @params[:lings_props] || {}
  end

  def lings_prop_param_conditions(depth)
    conditions = lings_prop_param_pairs(depth).inject({:id => nil}) do |conds, pair|
      conds | { :property_id => pair.first, :value => pair.last }
    end
  end

  def lings_prop_param_pairs(depth)
    vals = lings_prop_params.reject { |k,v| !category_present?(k, depth) }.values
    vals.flatten.map { |str| str.split(":") }
  end

  def categorized_to_depth(cat_params = nil)
    return {} if cat_params.nil?
    result = {}.tap do |hash|
      [parent, child].each do |depth|
        hash[depth.to_s] = group_prop_category_ids(depth).inject([]) do |memo, id|
          memo << cat_params[id.to_s]
        end.flatten.compact
      end
    end.delete_if {|k,v| v.empty? }
  end

  def group_prop_category_ids(depth)
    group_categories.ids.at_depth(depth).map(&:id)
  end

  def group_categories
    @group_categories ||= Category.in_group(@group)
  end

  def category_present?(key, depth)
    group_prop_category_ids(depth).map(&:to_s).include?(key)
  end

  def filter_by_all_conditions(depth_0_vals, depth_1_vals, grouping)
    all_selection = @params[grouping].group_by { |k,v| v }["all"]
    if all_selection
      cats = all_selection.map { |c| c.first }.map(&:to_i) # get category ids to group by all
      parent_cats = group_prop_category_ids(parent).select { |c| cats.include?(c) }
      child_cats = group_prop_category_ids(child).select { |c| cats.include?(c) }
      if parent_cats.any?
        parent_prop_ids = Property.ids.where(:category_id => parent_cats, :id => prop_filter.ids(parent))
        depth_0_vals    = depth_0_vals.ling_ids.group("lings_properties.property_id").having(:property_id => parent_prop_ids)
      end
      if child_cats.any?
        child_prop_ids  = Property.ids.where(:category_id => child_cats, :id => prop_filter.ids(child))
        depth_1_vals    = depth_1_vals.ling_ids.group(:property_id).having(:property_id => child_prop_ids)
      end

      intersect_lings_prop_ids(depth_0_vals, depth_1_vals)
    else
      [depth_0_vals, depth_1_vals]
    end
  end

  class QueryFilter
    def initialize(group, params = {})
      @group, @params = group, params
    end

    def ids(depth)
      selected(depth) || all.at_depth(depth)
    end

    def selected(depth)
      params[depth.to_s]
    end

    def all
      @all ||= klass.ids.in_group(@group)
    end

    def params
      @params || {}
    end

    def klass
      /Ling|Property/.match(self.class.name)[0].constantize
    end
  end

  class LingFilter < QueryFilter
  end

  class PropertyFilter < QueryFilter
  end

end