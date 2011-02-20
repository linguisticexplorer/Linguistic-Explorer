# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'fastercsv'

ling_list = {}
prop_list = {}

def ling_name(name)
  "ling #{name}".titleize
end

def prop_name(name)
  "prop #{name}".titleize
end

def group_name(name)
  name.titleize
end

# Create Groups
FasterCSV.foreach(Rails.root.join("doc", "data", "Ling.csv"), :headers => true) do |row|
  group = Group.find_or_create_by_name(group_name(row["group"]))
end

# Create Lings
FasterCSV.foreach(Rails.root.join("doc", "data", "Ling.csv"), :headers => true) do |row|
  name = ling_name(row["name"])
  ling = Ling.find_or_initialize_by_name(name) do |l|
    l.depth   = row["depth"]
    l.group   = Group.find_by_name(group_name(row["group"]))
  end
  ling_list[row["id"]] = name
  ling.save!
end

# Associate Lings with parents
FasterCSV.foreach(Rails.root.join("doc", "data", "Ling.csv"), :headers => true) do |row|
  next if row["parentid"].blank?

  child   = Ling.find_by_name(ling_name(row["name"]))
  parent  = Ling.find_by_name(ling_name(row["parentid"]))
  child.parent = parent
  child.group  = parent.group # Fix data to ensure child is in same group as parent
  child.save!
end

# Create Properties
FasterCSV.foreach(Rails.root.join("doc", "data", "Property.csv"), :headers => true) do |row|
  name     = prop_name(row["name"])
  property = Property.find_or_initialize_by_name(name) do |p|
    p.depth     = row["depth"]
    p.category  = row["category"]
    p.group     = Group.find_by_name(group_name(row["group"]))
  end
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

# Create LingsProperties

FasterCSV.foreach(Rails.root.join("doc", "data", "LingsProperty.csv"), :headers => true) do |row|
  prop  = Property.find_by_name(prop_list[row["propid"]])
  ling  = Ling.find_by_name(ling_list[row["lingid"]])

  attributes = {
    :property_id  => prop.id,
    :ling_id      => ling.id,
    :value        => MEANINGFUL_VALUES[row["value"]]
  }
  
  next if LingsProperty.where(attributes).first.present?
  lp          = LingsProperty.new(attributes)
  
  prop.group  = ling.group
  prop.save!
  lp.group    = ling.group
  lp.save!
end
