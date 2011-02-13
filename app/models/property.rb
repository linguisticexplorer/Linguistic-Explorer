class Property < ActiveRecord::Base
  validates_presence_of :name, :category, :depth
  validates_uniqueness_of :name
  validates_numericality_of :depth

end
