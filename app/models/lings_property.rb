class LingsProperty < ActiveRecord::Base
  validates_presence_of :value, :property, :ling, :group
  validates_existence_of :ling, :property, :group
  validates_uniqueness_of :value, :scope => [:ling_id, :property_id]
  validate :association_depth_match
  validate :group_association_match
  validates_existence_of :creator, :allow_nil => true

  belongs_to :ling
  belongs_to :property
  belongs_to :group
  belongs_to :creator, :class_name => "User"
  has_one :category, :through => :property

  scope :in_group, lambda { |group| where(:group => group) }
  scope :ids, select("#{self.table_name}.id")
  scope :ling_ids, select("#{self.table_name}.ling_id")
  scope :prop_ids, select("#{self.table_name}.property_id")

  scope :with_id, lambda { |id_or_ids| where("#{self.table_name}.id" => id_or_ids) }
  scope :with_ling_id, lambda { |id_or_ids| where("#{self.table_name}.ling_id" => id_or_ids) }

  scope :property_relatives, lambda { |prop_id| join(:lings).where("#{self.table_name}.property_id") }


  def self.group_by_statement
    LingsProperty.column_names.map { |c| "lings_properties.#{c}"}.join(", ")
  end

  def ling_name
    ling.name
  end

  def prop_name
    property.name
  end

  def prop_id
    property_id
  end

  def category_id
    property.category_id
  end

  def association_depth_match
    errors.add(:depth, "Must choose lings and properties with matching depth") if ling && property && ling.depth != property.depth
  end

  def group_association_match
    errors.add(:group, "#{ling.type_name} and #{group.property_name} must belong to the same group as this #{group.lings_property_name}") if (ling && property) && (ling.group != property.group || ling.group != group)
  end
end
