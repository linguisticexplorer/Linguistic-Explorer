class Property < ActiveRecord::Base
  validates_presence_of :name, :category
  validates_uniqueness_of :name

end
