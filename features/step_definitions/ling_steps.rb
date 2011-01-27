Given /^the following lings:$/ do |table|
  table.hashes.each do |attrs|
    Factory(:ling, attrs)
  end
end