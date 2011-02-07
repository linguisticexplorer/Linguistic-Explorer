When /^I allow all languages$/ do
  # no op
end

Then /^I should see the following search results:$/ do |table|
  table.hashes.each do |row|
    ling  = Ling.find_by_name(row["Languages"])
    prop  = Property.find_by_name(row["Properties"])

    scope = "".tap do |s|
      s << %Q|[data-ling*="#{ling.id}"]| if ling
      s << %Q|[data-prop*="#{prop.id}"]| if prop
    end

    with_scope(scope) do
      page.should have_content(ling.name)
      page.should have_content(prop.name)
    end
  end
end