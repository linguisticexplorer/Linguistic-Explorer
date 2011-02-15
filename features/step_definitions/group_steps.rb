Given /^the group "([^\"]*)"$/ do |name|
  @group = Group.find_by_name(name) || Factory(:group, :name => name)
end