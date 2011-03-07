class Example < ActiveRecord::Base
  validates_existence_of :ling, :allow_nil => true
  validates_existence_of :group
  validates_presence_of :group
  validate :group_association_match
  validates_existence_of :creator, :allow_nil => true

  belongs_to :ling
  belongs_to :group
  belongs_to :creator, :class_name => "User"

  def group_association_match
    errors.add(:group, "Ling must belong to the same group as this Example") if ling && (ling.group != group)
  end
end
