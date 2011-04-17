def create_user(attrs = {})
  raise "You must manually specify an email for a new user because emails must be unique" unless attrs[:email]
  Factory(:user, attrs)
end