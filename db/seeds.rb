# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'csv'
logger = Logger.new(STDOUT)

cat_list  = {}
user_list = {}
ling_list = {}
prop_list = {}
example_list = {}
lings_property_list = {}

def ling_name(name)
  "ling #{name}".titleize
end

def prop_name(name)
  "prop #{name}".titleize
end

def group_name(name)
  name.titleize
end

def category_name(name)
  name.titleize
end

puts "Starting Users..."
# Create Users(id,name,email,accesslevel)
CSV.foreach(Rails.root.join("doc", "data", "User.csv"), :headers => true) do |row|
  user = User.find_by_email(row["email"])
  user_list[row["id"]] = row["email"]

  next if user.present?

  user = User.new(
      :name => row["name"],
      :password => "hunter2",
      :password_confirmation => "hunter2"
  )
  user.access_level = row["accesslevel"]
  user.email = row["email"]
  user.save!
  user_list[row["id"]] = row["email"]
end

puts "Done with Users, starting Groups"
# Create Groups(id,name,privacy)
CSV.foreach(Rails.root.join("doc", "data", "Group.csv"), :headers => true) do |row|
  group = Group.find_or_create_by_name(group_name(row["name"]))
  group.depth_maximum  ||= 1
  group.ling0_name     ||= "Parent"
  group.ling1_name     ||= "Child"
  group.example_name   ||= "Example"
  group.property_name  ||= "Property"
  group.category_name  ||= "Category"
  group.depth_maximum  ||= 1
  group.example_fields ||= "gloss, number"
  group.lings_property_name ||= "Value"
  group.examples_lings_property_name ||= "ExampleValue"

  group.privacy = row["privacy"].downcase
  group.save!
end

puts "Done with Group, starting Memberships"
# Create GroupMemberships(id,user_id,group_id,level)
CSV.foreach(Rails.root.join("doc", "data", "GroupMembership.csv"), :headers => true) do |row|
  user = User.find_by_email(user_list[row["user_id"]])
  group = Group.find_by_name(group_name(row["group_id"]))
  Membership.create(:user => user, :group => group, :level => row["level"])
end

puts "Done with Memberships, starting Lings"
# Create Lings(id,name,parentid,depth,group,creator,timestamp)
CSV.foreach(Rails.root.join("doc", "data", "Ling.csv"), :headers => true) do |row|
  name = ling_name(row["name"])
  ling = Ling.find_or_initialize_by_name(name) do |l|
    l.depth = row["depth"]
    l.group = Group.find_by_name(group_name(row["group"]))
  end
  ling_list[row["id"]] = name
  ling.save!
end

puts "Done with Lings, starting ling parent associations"
# Associate Lings with parents
CSV.foreach(Rails.root.join("doc", "data", "Ling.csv"), :headers => true) do |row|
  next if row["parentid"].blank?

  child = Ling.find_by_name(ling_name(row["name"]))
  parent = Ling.find_by_name(ling_name(row["parentid"]))
  child.parent = parent

  begin
    child.save!
  rescue
    logger.warn child.errors.full_messages.join(". ")
    logger.warn parent.inspect
    logger.warn child.inspect
    logger.warn ""
  end
end

puts "Done with Ling parents, starting Categories"
# Create Categories(id,name,depth,group,creator,timestamp)
CSV.foreach(Rails.root.join("doc", "data", "Category.csv"), :headers => true) do |row|
  name = category_name(row["name"])
  category = Category.find_or_initialize_by_name(name)
  category.depth = row["depth"]
  category.group = Group.find_by_name(group_name(row["group"]))
  cat_list[row["name"]] = name

  category.save!
end

puts "Done with Categories, starting Properties"
# Create Properties(id,name,category,group,creator,timestamp)
CSV.foreach(Rails.root.join("doc", "data", "Property.csv"), :headers => true) do |row|
  name = prop_name(row["name"])
  property = Property.find_or_initialize_by_name(name)
  property.category = Category.find_by_name(cat_list[row["category"]])
  property.group = Group.find_by_name(group_name(row["group"]))
  prop_list[row["id"]] = name

  property.save!
end

MEANINGFUL_VALUES = {
 "0" => "Yes",
 "1" => "No",
 "2" => "Not set yet",
 "3" => "Not applicable",
 "4" => "Maybe"
}

puts "Done with Properties, starting Examples"
# Create Examples(id,lingid,group,creator,timestamp)
number = 0
CSV.foreach(Rails.root.join("doc", "data", "Example.csv"), :headers => true) do |row|
  number += 1
  name = number.to_s
  ling = Ling.find_by_name(ling_name(row["lingid"]))
  group = Group.find_by_name(group_name(row["group"]))

  example = Example.new(:name => name)
  example.ling = ling
  example.group = group
  example.save!
  example_list[row["id"].to_s] = example.id
end

puts "Done with Examples, starting LingsProperties"
# Create LingsProperties(id,lingid,propid,value,group,creator,timestamp)
CSV.foreach(Rails.root.join("doc", "data", "LingPropVal.csv"), :headers => true) do |row|
  group = Group.find_by_name(group_name(row["group"]))
  ling = Ling.in_group(group).find_by_name(ling_list[row["lingid"]])
  prop = Property.in_group(group).find_by_name(prop_list[row["propid"]])

  attributes = {
    :ling_id      => ling.id,
    :property_id  => prop.id,
    :value        => MEANINGFUL_VALUES[row["value"]]
  }

  already_exists = LingsProperty.where(attributes).first
  if already_exists.present?
    lings_property_list[row["id"]] = already_exists.id
  else
    lp = LingsProperty.new(attributes)
    lp.group = ling.group
    lp.save!
    lings_property_list[row["id"]] = lp.id
  end
end

puts "Done with LingsProperties, starting ExamplesLingsProperties"
# Create ExamplesLingsProperties(id,exampleid,LingPropValID,group,creator,timestamp)
CSV.foreach(Rails.root.join("doc", "data", "ExampleLingPropVal.csv"), :headers => true) do |row|
  group = Group.find_by_name(group_name(row["group"]))
  example = Example.in_group(group).find(example_list[row["exampleid"]])
  lp_id = lings_property_list[row["LingPropValID"].to_s]
  lings_property = LingsProperty.in_group(group).find(lp_id)
  attributes = {
    :example_id => example.id,
    :lings_property_id => lings_property.id,
  }
  next if ExamplesLingsProperty.where(attributes).first.present?

  elp = ExamplesLingsProperty.new(attributes)
  elp.group = group
  elp.save!
end

puts "Done with ExamplesLingsPropsVals"

puts "Seeding complete!"
