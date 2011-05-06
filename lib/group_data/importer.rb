# GroupDataImporter
#
# ==> Category.csv <==
# id,name,depth,group_id,creator_id,description
#
# ==> Example.csv <==
# id,name,ling_id,group_id,creator_id
#
# ==> ExampleLingsProperty.csv <===
# id,example_id,lings_property_id,group_id,creator_id
#
# ==> Group.csv <==
# id, name, privacy, depth_maximum, ling0_name, ling1_name, property_name, category_name, lings_property_name, example_name, examples_lings_property_name, example_fields
#
# ==> Ling.csv <==
# id,name,parent_id,depth,group_id,creator_id
#
# ==> LingsProperty.csv <==
# id,ling_id,property_id,value,group_id,creator_id
#
# ==> Membership.csv <==
# id,member_id,group_id,level,creator_id
#
# ==> Property.csv <==
# id,name,description,category,group_id,creator_id
#
# ===> StoredValue.csv <=====
# id, storable_id, storable_type, key, value, group_id
#
# ==> User.csv <==
# id,name,email,access_level,password
#

module GroupData
  class Importer

  end

end