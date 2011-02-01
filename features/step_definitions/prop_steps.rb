Given /^the following properties:$/ do |table|
  table.hashes.each do |attrs|
    Property.find_by_name(attrs['name']) || Factory(:property, attrs)
  end
end