class Example < ActiveRecord::Base
  validates_existence_of :ling, :allow_nil => true
  validates_existence_of :group
  validates_presence_of :group_id
  validate :group_association_match

  belongs_to :ling
  belongs_to :group

  def group_association_match
    errors.add(:group, "Ling must belong to the same group as this Example") if ling && (ling.group != group)
  end
end
