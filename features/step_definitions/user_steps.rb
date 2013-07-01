Given /^I am a visitor$/ do
  visit destroy_user_session_path
end

Given /^I am signed in as a ([^ ]+) of (.*)/ do |membership_level, group|
  password  = "hunter2"
  email = "e@mail.com"
  level = (Membership::ADMIN == membership_level ? membership_level : Membership::MEMBER )

  @user = create_user(:email => email, :password => password)
  @group = Group.find_by_name(group) || Factory(:group, :name => group)
  Membership.create!(:member => @user, :group => @group, :level => level)

  visit path_to("the home page")
  click_link "Sign In"
  fill_in "Email",    :with => email
  fill_in "Password", :with => password
  click_button "Sign In"
end

Given /^I am signed in as "(.*)"/ do |email|
  password  = "hunter2"
  @user     = User.find_by_email(email) || create_user(:email => email, :password => password)

  visit path_to("the home page")
  click_link "Sign In"

  fill_in "Email",    :with => email
  fill_in "Password", :with => password
  click_button "Sign In"
end

Given /^the following users:$/ do |table|
  table.hashes.each do |attrs|
    next if User.find_by_email attrs[:email]
    create_user(attrs)
  end
end
