When /^I allow all languages$/ do
  # no op
end

Then /^I should see the following search results:$/ do |table|
  table.hashes.each do |row|
    ling  = Ling.find_by_name(row["Lings"]) if row["Lings"]
    prop  = Property.find_by_name(row["Properties"]) if row["Properties"]
    lp   = LingsProperty.find_by_value(row["Value"]) if row["Value"]

    scope = "".tap do |s|
      s << %Q|[data-ling*="#{ling.id}"]| if ling
      s << %Q|[data-prop*="#{prop.id}"]| if prop
    end

    with_scope(scope) do
      page.should have_content(ling.name) if ling
      page.should have_content(prop.name) if prop
      page.should have_content(lp.value) if lp
    end
  end
end
