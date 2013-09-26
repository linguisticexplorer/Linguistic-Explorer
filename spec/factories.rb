FactoryGirl.define do
  factory :group do |f|
    f.name           "The Best Group"
    f.privacy        Group::PUBLIC
    f.depth_maximum  Group::MAXIMUM_ASSIGNABLE_DEPTH
    f.example_fields "gloss, number"
  end
end

FactoryGirl.define do
  factory :user do |f|
    f.name          "Bob Jones"
    f.email         "bob@example.com"
    f.access_level  "user"
    f.password      "password"
  end
end

FactoryGirl.define do
  factory :ling do |f|
  f.name "English"
  f.depth 0
  f.association :group, :factory => :group
  end
end

FactoryGirl.define do
  factory :membership do |f|
  f.level "member"
  f.association :group, :factory => :group
  f.association :member, :factory => :user
  end
end

FactoryGirl.define do
  factory :property do |f|
  f.name "Adjective"
# NOTE: You must pass the following two yourself because the category must belong to the same group as the created property
#  f.association :category, :factory => :category
#  f.association :group, :factory => :group
  end
end

FactoryGirl.define do
  factory :category do |f|
  f.name "Grammar"
  f.depth 0
  f.association :group, :factory => :group
  end
end

FactoryGirl.define do
  factory :lings_property do |f|
  end
end

FactoryGirl.define do
  factory :example do |f|
  f.name "SampleExample"
# NOTE: You must pass the following two yourself because the ling must belong to the same group as the created example
#  f.association :group, :factory => :group
#  f.association :ling, :factory => :ling
  end
end

FactoryGirl.define do
  factory :examples_lings_property do |f|

  end
end

FactoryGirl.define do
  factory :search do |f|
  f.name "New Search"
  f.association :group, :factory => :group
  f.association :creator, :factory => :user
  end
end

FactoryGirl.define do
  factory :stored_value do |f|

  end

end

FactoryGirl.define do
  factory :forum_group do |f|
    f.position 0
  end
end

FactoryGirl.define do
  factory :forum do |f|
    f.description "Generic Forum"
    f.position 0
  end
end

FactoryGirl.define do
  factory :topic do |f|
    f.body "Bla bla"
    f.association :user, :factory => :user
  end
end

FactoryGirl.define do
  factory :post do |f|
    f.body "Blah blah blah"
    f.association :user, :factory => :user
  end
end
