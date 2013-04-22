Given /^the ([^ ]*?) group "([^\"]*)"$/ do |privacy, name|
  step %{the group "#{name}"}
  @group.privacy = privacy
  @group.save
end

Given /^the group "([^\"]*)"$/ do |name|
  @group = Group.find_by_name(name) || FactoryGirl.create(:group, :name => name)
end

Given /^the group "([^\"]*)" has a maximum depth of (\d)$/ do |name,depth|
  step %{the group "#{name}"}
  @group.depth_maximum = depth.to_i
  @group.save!
end

Given /^the group "([^\"]*)" with the following ling names:$/ do |name, table|
  step %{the group "#{name}"}
  table.hashes.each do |attrs|
    @group.ling0_name = attrs["ling0_name"]
    if attrs["ling1_name"]
      @group.ling1_name = attrs["ling1_name"]
    else
      @group.depth_maximum = 0
    end
    @group.save!
  end
end
