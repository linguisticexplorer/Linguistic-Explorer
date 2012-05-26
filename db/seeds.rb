# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'csv'

config = YAML.load_file((Rails.root.join("db", "seed", "seed.yml")))
GroupData::Importer.import(config)

puts "Creating Admin User..."
# create a toy admin account
User.create(:name => "admin", :password => "password", :password_confirmation => "password" ) do |u|
  u.access_level = User::ADMIN
  u.email = "a@dmin.com"
end

puts "Seeding complete!"