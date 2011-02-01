class Ling < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :examples

  def add_property(value, property)
    LingsProperty.create!(:ling => self, :property => property, :value => value)
  end

end
