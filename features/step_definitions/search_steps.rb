When /^I allow all languages$/ do
  # no op
end

Then /^I should see the following search results:$/ do |table|
  table.hashes.each do |row|
    ling  = Ling.find_by_name(row["Languages"])
    prop  = Property.find_by_name(row["Properties"])
    lp    = LingsProperty.find_by_ling_id_and_property_id(ling.id, prop.id)
    
    ling_property_search_row = ".#{dom_id(lp)}_result"
    
    with_scope(ling_property_search_row) do
      page.should have_content(ling.name)
      page.should have_content(prop.name)
    end
  end
end