Given /^the following "([^\"]*)" properties:$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist! Did you remember to create it first?" if group.nil?

  table.hashes.each do |attrs|
    prop_attrs = {}.tap do |opts|
      cat_name = attrs.delete('category')
      opts[:name]      = attrs['property name']
      opts[:category]  = Category.find_by_name(cat_name) || Factory(:category, :group => group)
      opts[:group]     = group
    end
    property = Property.find_by_name(prop_attrs[:name]) || Factory(:property, prop_attrs)

    ling = group.lings.find_by_name(attrs["ling name"])
    raise "Ling #{attrs['ling name']} does not exist! Did you remember to create it first?" if ling.nil?

    ling.add_property(attrs["prop val"], property)
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
      opts[:category]  = attrs['category']  unless attrs['category'].blank?
      opts[:depth]     = attrs['depth'].to_i || 0
      opts[:group]     = group
    end

    prop = group.properties.find_by_name(prop_attrs[:name]) || Factory(:property, prop_attrs)
    ling.add_property(attrs['prop val'], prop)
  end
end

Then /^the select menu for "([^\"]*)" should contain the following:$/ do |label, table|
  table.hashes.each do |hash|
    with_scope("##{label.underscorize}") do
      page.should have_content(hash["option"])
    end
  end
end

Then /^the select menu for "([^\"]*)" should not contain the following:$/ do |label, table|
  table.hashes.each do |hash|
    with_scope("##{label.underscorize}") do
      page.should_not have_content(hash["option"])
    end
  end
end
