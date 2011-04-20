Given /^I have a saved group search "([^\"]*)"$/ do |search_name|
  Factory(:search, :name => search_name, :user => @user, :group => @group)
end

When /^I allow all languages$/ do
  # no op
end

Then /^I should see the following search results:$/ do |table|
  table.hashes.each do |row|
    ling  = Ling.find_by_name(row["Lings"]) if row["Lings"]
    prop  = Property.find_by_name(row["Properties"]) if row["Properties"]

    lp = if row["Value"]
      LingsProperty.find_by_ling_id_and_property_id_and_value(ling.id, prop.id, row["Value"])
    elsif ling && prop
      LingsProperty.find_by_ling_id_and_property_id(ling.id, prop.id)
    elsif ling
      LingsProperty.find_by_ling_id(ling.id)
    elsif prop
      LingsProperty.find_by_property_id(prop.id)
    end
    example = Example.find_by_name_and_ling_id(row["Example"], ling.id) if row["Example"]
    depth = (row["depth"] || "parent").downcase

    with_scope(%Q|[data-#{depth}-value="#{lp.id}"]|) do
      page.should have_content(ling.name)     if ling
      page.should have_content(prop.name)     if prop
      page.should have_content(lp.value)      if row["Value"]
      page.should have_content(example.name)  if example
    end
  end
end
