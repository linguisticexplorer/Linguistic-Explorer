Given /^the following "([^\"]*)" lings:$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist? Did you remember to create it first?" if group.nil?

  table.hashes.each do |hash|
    attrs = hash.dup
    parent = nil

    unless attrs["parent"].blank?
      parent = find_or_create_ling(:name => attrs['parent'], :depth => Depth::PARENT, :group => group)
    end
    
    find_or_create_ling({:name => attrs['name'], :depth => attrs['depth'], :parent => parent, :group => group})
  end
end

Given /^the group has a maximum depth of (\d+)$/ do |depth|
  Group.last.update_attribute(:depth_maximum, depth.to_i)
end

Given /^the following "([^\"]*)" examples:$/ do |arg1, table|
  table.hashes.each do |hash|
    attrs = hash.dup

    ling  = Ling.find_by_name(attrs["ling name"])
    group = Group.last
    example = FactoryGirl.create(:example, :name => attrs["example"], :ling => ling, :group => group)

    lings_property = LingsProperty.find_by_value(attrs["prop val"])
    FactoryGirl.create(:examples_lings_property, :example => example, :lings_property => lings_property, :group => group)
  end
end

When /^(?:|I )follow the "([^\"]*)" (?:with depth "([^\"]*)" )model link for (?:|the group )"([^\"]*)"(?: within "([^\"]*)")?$/ do |model,depth,group_name,selector|
    with_scope(selector) do
      group = Group.find_by_name(group_name)
      model_field = "#{model}#{depth ? depth : ""}_name"
      link = group.send(model_field.downcase).to_s
      # click_link(link)
      first(:link, link).click
    end
end