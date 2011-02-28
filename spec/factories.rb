Factory.define :user do |f|
  f.name "Bob"
  f.email "bob@example.com"
  f.access_level "user"
  f.password "password"
end

Factory.define :ling do |f|
  f.name "English"
  f.depth 0
  f.association :group, :factory => :group
end

Factory.define :property do |f|
  f.name "Adjective"
  f.association :category, :factory => :category
  f.association :group, :factory => :group
end

Factory.define :category do |f|
  f.name "Grammar"
  f.depth 0
  f.association :group, :factory => :group
end

Factory.define :group do |f|
  f.name "The Best Group"
end
