Given /^the following "([^\"]*)" lings:$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist? Did you remember to create it first?" if group.nil?

  table.hashes.each do |hash|
    attrs = hash.dup
    parent = nil

    unless attrs["parent"].blank?
      parent = group.lings.find_by_name(attrs['parent']) ||
        Factory(:ling, :name => attrs['parent'], :depth => 0, :group => group)
    end

    group.lings.find_by_name(attrs['name']) ||
      Factory(:ling, attrs.merge(:parent => parent, :depth => attrs['depth'], :group => group))
  end
end

When /^(?:|I )follow the "([^"]*)" (?:with depth "([^"]*)" )model link for (?:|the group )"([^"]*)"(?: within "([^"]*)")?$/ do |model,depth,group_name,selector|
    with_scope(selector) do
      group = Group.find_by_name(group_name)
      model_field = "#{model}#{depth ? depth : ""}_name"
      link = group.send(model_field.downcase).to_s
      click_link(link)
    end
end
