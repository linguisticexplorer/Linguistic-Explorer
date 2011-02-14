class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :lings
  has_many :properties
  has_many :lings_properties
  has_many :examples
end
