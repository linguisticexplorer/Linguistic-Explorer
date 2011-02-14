class Property < ActiveRecord::Base
  validates_presence_of :name, :category, :depth, :group
  validates_uniqueness_of :name
  validates_numericality_of :depth
  validates_existence_of :group

  belongs_to :group
end
