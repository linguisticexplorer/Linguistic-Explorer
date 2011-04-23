def create_user(opts = {})
  raise "You must manually specify an email for a new user because emails must be unique" unless opts[:email]
  Factory(:user, opts)
end

def find_or_create_ling(opts = {})
  find_or_create_groupable_resource(:ling, opts)
end

def find_or_create_property(opts = {})
  find_or_create_groupable_resource(:property, opts)
end

def find_or_create_category(opts = {})
  find_or_create_groupable_resource(:category, opts)
end

def find_or_create_groupable_resource(resource_name, opts)
  group = opts[:group]
  group.send(resource_name.to_s.pluralize).find_by_name(opts[:name]) || Factory(resource_name, opts)
end

def find_or_create_lings_property(opts = {})
  group     = opts[:group]
  ling      = opts[:ling]
  property  = opts[:property]
  value     = opts[:value]
  group.lings_properties.find_by_ling_id_and_property_id_and_value(ling.id, property.id, value) || ling.add_property(value, property)
end