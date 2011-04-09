When /^I allow all languages$/ do
  # no op
end

Then /^I should see the following search results:$/ do |table|
  table.hashes.each do |row|
    ling  = Ling.find_by_name(row["Lings"]) if row["Lings"]
    prop  = Property.find_by_name(row["Properties"]) if row["Properties"]
    lp    = LingsProperty.find_by_ling_id_and_property_id_and_value(ling.id, prop.id, row["Value"]) if row["Value"]
    example = Example.find_by_name_and_ling_id(row["Example"], ling.id) if row["Example"]
    depth = (row["depth"] || "parent").downcase

    scope = "".tap do |s|
      s << %Q|[data-#{depth}-ling="#{ling.id}"]|      if ling
      s << %Q|[data-#{depth}-property="#{prop.id}"]|  if prop
      s << %Q|[data-#{depth}-value="#{lp.id}"]|       if lp
    end

    with_scope(scope) do
      page.should have_content(ling.name) if ling
      page.should have_content(prop.name) if prop
      page.should have_content(lp.value) if lp
      page.should have_content(example.name) if example
    end
  end
end
