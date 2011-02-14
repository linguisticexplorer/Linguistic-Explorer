class LingsProperty < ActiveRecord::Base
  validates_presence_of :value, :property_id, :ling_id, :group_id
  validates_existence_of :ling, :property, :group
  validate :association_depth_match
  validate :group_association_match

  belongs_to :ling
  belongs_to :property
  belongs_to :group

  def ling_name
    ling.name
  end
  
  def prop_name
    property.name
  end

  def association_depth_match
    errors.add(:depth, "Must choose lings and properties with matching depth") if ling && property && ling.depth != property.depth
  end

  def group_association_match
    errors.add(:group, "Ling and Property must belong to the same group as this Value") if (ling && property) && (ling.group != property.group || ling.group != group)
  end
end
