Given /^I am a visitor$/ do
  # no op
end

Given /^I am signed in as "(.*)"/ do |email|
  password  = "hunter2"
  @user     = User.find_by_email(email) || create_user(:email => email, :password => password)

  visit path_to("the home page")
  click_link "sign in"

  fill_in "Email",    :with => email
  fill_in "Password", :with => password
  click_button "Sign in"
end

Given /^the following users:$/ do |table|
  table.hashes.each do |attrs|
    next if User.find_by_email attrs[:email]
    create_user(attrs)
  end
end
