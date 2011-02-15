Given /^the following lings:$/ do |table|
  table.hashes.each do |attrs|
    group_name = attrs.delete('group')
    group = Group.find_by_name(group_name) || Factory(:group, :name => group_name)
    group.lings.find_by_name(attrs['name']) || Factory(:ling, attrs.merge(:group => group))
  end
end

Given /^the following lings and properties:$/ do |table|
  table.hashes.each do |attrs|
    group_name = attrs.delete('group')
    group = Group.find_by_name(group_name) || Factory(:group, :name => group_name)
    
    ling_attrs = {:name => attrs['name'], :depth => attrs['depth'].to_i}
    ling = group.lings.find_by_name(attrs['name']) || Factory(:ling, ling_attrs.merge(:group => group))

    prop_attrs = {}.tap do |opts|
      opts[:name]      = attrs['property_name']      unless attrs['property_name'].blank?
      opts[:category]  = attrs['property_category']  unless attrs['property_category'].blank?
      opts[:depth]     = attrs['depth'].to_i || 0
      opts[:group]     = group
    end

    prop = group.properties.find_by_name(prop_attrs[:name]) || Factory(:property, prop_attrs)
    ling.add_property(attrs['property_value'], prop)
  end
end
