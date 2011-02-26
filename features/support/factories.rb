Factory.define :ling do |f|
  f.name "English"
  f.depth 0
  f.association :group, :factory => :group
end

Factory.define :property do |f|
  f.name "Adjective"
  f.category "Grammar"
  f.depth 0

  f.group
end

Factory.define :group do |f|
  f.name "The Best Group"
end
