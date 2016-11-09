Given /^I am a visitor$/ do
  visit destroy_user_session_path
end

Given /^I am signed in as a ([^ ]+) of (.*)/ do |membership_level, group|
  password = "hunter2"
  email    = "e@mail.com"
  level    = (Membership::ADMIN == membership_level ? membership_level : Membership::MEMBER )
  options  = {
    group: group,
    level: level
  }

  log_in(email, password, options)
end

Given /^I am signed in as an expert member of (.*) for lings:?$/ do |group, table|
  email    = "e@mail.com"
  password = "hunter2"
  options  = {
    group: group,
    level: Membership::MEMBER
  }

  membership = sign_up(email, password, options)

  add_membership2lings_role_from_table(membership, :expert, table)

  sign_in(email, password)
end

Given /^I am signed in as "(.*)"/ do |email|
  password  = "hunter2"

  log_in(email, password)
end

Given /^a user with email "([^\"]+)" is a ([^ ]+) of (.*)/ do |email, membership_level, group|
  password  = "hunter2"
  options   = {
    group: group,
    level: Membership::ADMIN == membership_level ? membership_level : Membership::MEMBER
  }

  sign_up(email, password, options)
end

Given /^a user with email "([^\"]+)" is an expert member of (.*) for lings:?$/ do |email, group, table|
  password  = "hunter2"
  options   = {
    group: group,
    level: Membership::MEMBER
  }

  membership = sign_up(email, password, options)

  add_membership2lings_role_from_table(membership, :expert, table)

end

Given /^the following users:$/ do |table|
  table.hashes.each do |attrs|
    next if User.find_by_email attrs[:email]
    create_user(attrs)
  end
end

When /^(?:|I )fill in the CAPTCHA correctly$/ do
  # Waiting for rspec 2.6
  # User.any_instance.stubs(:bypass_humanizer?).returns(true)
end
