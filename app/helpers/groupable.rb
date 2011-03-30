module Groupable
  def self.included(base)
    base.validates_presence_of  :group
    base.validates_existence_of :group
    base.validates_existence_of :creator, :allow_nil => true
    base.belongs_to :group
    base.belongs_to :creator, :class_name => "User"
  end
end
