Given /^I have a saved group search "([^\"]*)"$/ do |search_name|
  Factory(:search, :name => search_name, :creator => @user, :group => @group)
end

Given /^I have (\d+) saved group searches$/ do |num|
  num.to_i.times do |i|
    Factory(:search, :name => "My search #{i + 1}", :creator => @user, :group => @group)
  end
end

Given /^the following results for the group search "([^\"]*)":$/ do |search_name, table|
  parent_ids, child_ids = [], []

  table.hashes.each do |row|

    parent_ling = find_or_create_ling({
      :name => row['parent ling'],
      :group => @group,
      :depth => Depth::PARENT
    })
    child_ling = find_or_create_ling({
      :name => row['child ling'],
      :group => @group,
      :depth => Depth::CHILD,
      :parent => parent_ling
    })
    parent_property = find_or_create_property({
      :name => row['parent property'],
      :group => @group,
      :category => find_or_create_category(:name => 'Parent category', :group => @group, :depth => Depth::PARENT)
    })
    child_property = find_or_create_property({
      :name => row['child property'],
      :group => @group,
      :category => find_or_create_category(:name => 'Child category', :group => @group, :depth => Depth::CHILD)
    })

    parent_ids  << find_or_create_lings_property({
      :ling => parent_ling,
      :property => parent_property,
      :group => @group,
      :value => row['parent value']
    }).id

    child_ids   << find_or_create_lings_property({
      :ling => child_ling,
      :property => child_property,
      :group => @group,
      :value => row['child value']
    }).id
  end

  Factory(:search,
          :name => search_name,
          :parent_ids => parent_ids,
          :child_ids => child_ids,
          :group => @group,
          :creator => @user
  )
end

Given /^the group example fields "([^\"]*)"$/ do |text|
  @group.update_attribute(:example_fields, text)
end

Given /^the following example stored values$/ do |table|
  table.hashes.each do |attrs|
    example = Example.find_by_name(attrs['example'])
    Factory(:stored_value, :key => attrs['key'], :value => attrs['value'], :storable => example)
  end
end

When /^I allow all languages$/ do
  # no op
end

When /^I allow all properties$/ do
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

Then /^I should see the following Cross search results:$/ do |table|
  table.hashes.each do |row|
    prop_cols = row.keys.select {|col| /Name/.match(col)}
    props = [].tap do |prop|
      prop_cols.each do |col|
        prop << Property.find_by_name(row[col])
      end
    end

    lps_cols = row.keys.select {|col| /Value/.match(col)}
    lps = [].tap do |lp|
      lps_cols.each_index do |index|
        lp << LingsProperty.find_by_property_id_and_value(props[index].id, row[lps_cols[index]])
      end
    end

    calculated_div_id = lps.inject("p") {|memo, lp| "#{memo}-#{lp.prop_name.hash - lp.property_value.hash}" }
    with_scope(%Q|[data-parent-value="#{calculated_div_id}"]|) do
      props.each do |prop|
        page.should have_content(prop.name)
      end
      lps.each do |lp|
        page.should have_content(lp.value)
      end
      page.should have_content(row["Count"])
    end


  end
end

Then /^I should see the following grouped search results:$/ do |table|
  table.hashes.each do |row|
    parent_ling  = Ling.find_by_name(row["parent ling"])
    parent_prop  = Property.find_by_name(row["parent property"])
    child_ling  = Ling.find_by_name(row["child ling"])
    child_prop  = Property.find_by_name(row["child property"])

    parent_lp = begin
      if parent_ling
        LingsProperty.find_by_ling_id_and_property_id(parent_ling.id, parent_prop.id)
      else
        LingsProperty.find_by_property_id(parent_prop.id)
      end
    end
    child_lp  = begin
      if child_ling
        LingsProperty.find_by_ling_id_and_property_id(child_ling.id, child_prop.id)
      else
        LingsProperty.find_by_property_id(child_prop.id)
      end
    end

    with_scope(%Q|[data-parent-value="#{parent_lp.id}"][data-child-value="#{child_lp.id}"]|) do
      page.should have_content(parent_ling.name)
      page.should have_content(child_ling.name)
      page.should have_content(parent_prop.name)
      page.should have_content(child_prop.name)
      page.should have_content(row["parent value"])
      page.should have_content(row["child value"])
    end
  end
end

Then /^the csv should contain the following rows$/ do |table|
  csv_response = CSV.parse(page.body)
  columns = %w[col_1 col_2 col_3 col_4 col_5 col_6 col_7 col_8]

  table.hashes.each_with_index do |row, i|
    columns.each_with_index do |col, j|
      csv_response[i][j].should == row[col] unless row[col].nil?
    end
  end
end

Then /^I should see (\d+) search result rows?$/ do |count|
  page.should have_css("div.search_result.row", :count => count.to_i)
end

Then /^I should see (\d+) properties in common?$/ do |count|
  page.should have_css("div.search_common_result.row", :count => count.to_i)
end

Then /^I should see (\d+) properties not in common?$/ do |count|
  page.should have_css("div.search_diff_result.row", :count => count.to_i)
end

Then /^I should see (\d+) ling rows?$/ do |count|
  page.should have_css("div.search_ling_result.row", :count => count.to_i)
end

Then /^I should not see properties in common?$/ do
  page.should_not have_css("div.search_common_result.row")
end

Then /^I should see no search result rows?$/ do
  page.should_not have_css("div.search_result.row")
end

Then /^I should see a map?/ do
  #page.should have_css("div.map_canvas")
end