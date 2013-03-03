Given /^the following "([^"]*)" examples for properties$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist! Did you remember to create it first?" if group.nil?
  table.hashes.each do |attrs|
    ling = group.lings.find_by_name(attrs["ling name"])
    property = Property.find_by_name(attrs["property name"])
  end   
end

