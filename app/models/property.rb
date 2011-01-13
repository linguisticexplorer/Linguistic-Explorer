class Property < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :type
end
