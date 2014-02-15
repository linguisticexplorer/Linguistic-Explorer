And /^there is no value set for the ling "([^\"]*)" with the property "([^\"]*)"/ do |ling_name, property_name|
  ling = Ling.find_by_name(ling_name)
  property = Property.find_by_name(property_name)
  raise "Ling and Property must belong to the same group" if ling && property && ling.group != property.group
  val = LingsProperty.find_by_ling_id_and_property_id(ling.id, property.id)
  raise "LingsProperty with the ling #{ling_name} and property #{property_name}" if val.present?
end

Given /^the following "([^\"]*)" properties:$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist! Did you remember to create it first?" if group.nil?

  table.hashes.each do |attrs|
    prop_attrs = {}.tap do |opts|
      cat_name = attrs.delete('category') || "Grammar"
      opts[:name]      = attrs['property name']
      opts[:category]  = Category.find_by_name(cat_name) ||
        FactoryGirl.create(:category, :name => cat_name, :group => group, :depth => attrs['depth'])
      opts[:group]     = group
      # opts[:group]     = group
    end
    property = Property.find_by_name(prop_attrs[:name]) || FactoryGirl.create(:property, prop_attrs)

    ling = group.lings.find_by_name(attrs["ling name"])
    raise "Ling #{attrs['ling name']} does not exist! Did you remember to create it first?" if ling.nil?

    ling.add_property_sureness(attrs["prop val"], attrs['surety'], property)
  end
end

Given /^the following lings and properties:$/ do |table|
  table.hashes.each do |attrs|
    group_name = attrs.delete('group')
    group = Group.find_by_name(group_name) || FactoryGirl.create(:group, :name => group_name)

    ling_attrs = {:name => attrs['name'], :depth => attrs['depth'].to_i}
    ling = group.lings.find_by_name(attrs['name']) || FactoryGirl.create(:ling, ling_attrs.merge(:group => group))

    prop_attrs = {}.tap do |opts|
      cat_name = attrs.delete('category') || "Grammar"
      opts[:name]      = attrs['property_name']      unless attrs['property_name'].blank?
      opts[:category]  = Category.find_by_name(cat_name) || FactoryGirl.create(:category, :name => cat_name, :group => group, :depth => "0")
      opts[:group]     = group
    end

    prop = group.properties.find_by_name(prop_attrs[:name]) || FactoryGirl.create(:property, prop_attrs)
    ling.add_property(attrs['prop val'], prop)
  end
end

Given /^the following "([^\"]*)" definitions for properties$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist! Did you remember to create it first?" if group.nil?
  table.hashes.each do |attrs|
    property = group.properties.find_by_name(attrs['property name'])
    property.description = attrs['definition']
    property.save!
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
When /^I follow the "([^"]*)" for the group "([^"]*)"$/ do |model, group_name|
    group = Group.find_by_name(group_name)
    link = "#{model}"
    # click_link(link)
    first(:link, link).click
end
