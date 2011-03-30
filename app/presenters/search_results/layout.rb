module SearchResults
  module Layout
    HEADERS = [
      lambda { |g| "#{g.ling0_name}/#{g.ling1_name}" },
      lambda { |g| "Ling Type" },
      lambda { |g| g.property_name.pluralize.titleize },
      lambda { |g| g.lings_property_name.pluralize.titleize },
      lambda { |g| "Parent" }
    ]
    ROWS = [
      lambda { |g, r| r.ling_name },
      lambda { |g, r| g.ling_name_for_depth(r.ling.depth) },
      lambda { |g, r| r.prop_name },
      lambda { |g, r| r.value },
      lambda { |g, r| r.parent_name }
    ]
    
  end
end