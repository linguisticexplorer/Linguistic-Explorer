class Example < ActiveRecord::Base
  belongs_to :ling
  validates_existence_of :ling, :allow_nil => true
end
