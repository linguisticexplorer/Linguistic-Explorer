Given /^the following properties:$/ do |table|
  table.hashes.each do |hash|
    attrs = hash.dup
    if attrs['group']
      group_name = attrs.delete('group')
      attrs['group'] = Group.find_by_name(group_name) || Factory(:group, :name => group_name)
    end
    Property.find_by_name(attrs['name']) || Factory(:property, attrs)
  end
end