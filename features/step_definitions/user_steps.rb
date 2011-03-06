Given /^I am a visitor$/ do
  # no op
end

Given /^I am signed in as "(.*)"/ do |email|
  steps [
    "Given the following users:
        | name    | email         | password  | access_level  |
        | bob     | bob@dole.com  | hunter2   | user          |",
  'When I follow "sign in"',
  'Then I should be on the login page',
  'When I fill in "Email" with "' + email + '"',
  'And  I fill in "Password" with "hunter2"',
  'And  I press "Sign in"',
  'Then I should see "Signed in as ' + email + '"'
  ].join("\n")
end

Given /^the following users:$/ do |table|
  table.hashes.each do |attrs|
    next if User.find_by_email attrs[:email]
    u = User.new(:name => (attrs[:name] || "marley"), :password => (attrs[:password] || "hunter2"))
    u.email = attrs[:email] || raise("You must manually specify an email for a new user because emails must be unique")
    u.access_level = attrs[:access_level]
    u.save!
  end
end
