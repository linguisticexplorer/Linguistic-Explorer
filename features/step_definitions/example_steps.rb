Given /^the following "([^"]*)" examples for properties$/ do |group_name, table|
  group = Group.find_by_name(group_name)
  raise "Group #{group_name} does not exist! Did you remember to create it first?" if group.nil?
  table.hashes.each do |attrs|
    prop = Property.find_by_name(attrs["property name"])
    ling = Ling.find_by_name(attrs["ling name"])
    exam_attrs = {}.tap do |opts|
      opts[:group] = group
      opts[:ling] = ling
      opts[:name] = attrs["example name"]
    end
    example = Example.create(exam_attrs)
    lings_prop = prop.lings_properties.find_by_ling_id(ling.id)
    elp_attrs = {}.tap do |opts|
      opts[:group] = group
      opts[:lings_property] = lings_prop
      opts[:example] = example
    end
    example_lings_prop = ExamplesLingsProperty.create(elp_attrs)
  end   
end

