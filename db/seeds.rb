# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'csv'

config = YAML.load_file((Rails.root.join("db", "seed", "seed.yml")))

config.each do |key, value|
  config[key] = Rails.root.join("db", "seed", value)
end

GroupData::Importer.import(config)
# Default admin data
username = 'admin'
password = 'password'
email = 'a@dmin.com'

puts "Creating Admin User..."
# create a toy admin account
User.create(:name => username, :password => password, :password_confirmation => password ) do |u|
  u.access_level = User::ADMIN
  u.email = email
end

puts "Username: '#{username}'"
puts "Password: '#{password}'"
puts "Email: '#{email}'"

puts "Seeding complete!"