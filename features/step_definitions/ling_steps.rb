Given /^the following lings:$/ do |table|
  table.hashes.each do |attrs|
    group_name = attrs.delete('group')
    group = Group.find_by_name(group_name) || Factory(:group, :name => group_name)
    group.lings.find_by_name(attrs['name']) || Factory(:ling, attrs.merge(:group => group))
  end
end

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
