Given /^I am a visitor$/ do
  # no op
end

Given /^the following users:$/ do |table|
  table.hashes.each do |attrs|
      u = User.new(:name => (attrs[:name] || "marley"), :password => (attrs[:password] || "hunter2"))
      u.email = attrs[:email] || raise("You must manually specify an email for a new user because emails must be unique")
      u.access_level = attrs[:access_level]
      u.save!
  end
end
