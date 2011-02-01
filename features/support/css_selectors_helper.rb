def dom_id(object)
  "#{singular_class_name(object)}_#{object.id}"
end

def singular_class_name(object)
  object.class.base_class.name.tableize.singularize
end