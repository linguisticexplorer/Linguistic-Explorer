class LingsProperty < ActiveRecord::Base
  validates_presence_of :value, :property_id, :ling_id
  validates_existence_of :ling, :property
  validate :association_depth_match

  belongs_to :ling
  belongs_to :property

  def ling_name
    ling.name
  end
  
  def prop_name
    property.name
  end

  def association_depth_match
    errors.add(:depth, "Must choose lings and properties with matching depth") if ling && property && ling.depth != property.depth
  end
end
