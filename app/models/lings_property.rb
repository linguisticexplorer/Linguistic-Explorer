class LingsProperty < ActiveRecord::Base
  include Groupable

  validates_presence_of :value, :property, :ling
  validates_existence_of :ling, :property
  validates_uniqueness_of :value, :scope => [:ling_id, :property_id]
  validate :association_depth_match
  validate :group_association_match

  belongs_to :ling
  belongs_to :property
  has_one    :category, :through => :property

  has_many :examples_lings_properties, :dependent => :destroy
  has_many :examples, :through => :examples_lings_properties

  before_save  :set_property_value

  include Extensions::Selects
  include Extensions::Wheres

  scope :ling_ids, select("#{self.table_name}.ling_id")
  scope :prop_ids, select("#{self.table_name}.property_id")
  scope :property_value, select("#{self.table_name}.property_value")

  scope :with_id, lambda { |id_or_ids| where("#{self.table_name}.id" => id_or_ids) }
  scope :with_ling_id, lambda { |id_or_ids| where("#{self.table_name}.ling_id" => id_or_ids) }

  scope :property_relatives, lambda { |prop_id| join(:lings).where("#{self.table_name}.property_id") }

  def self.group_by_statement
    LingsProperty.column_names.map { |c| "lings_properties.#{c}"}.join(", ")
  end

  def self.select_ids
    ids.ling_ids.prop_ids.property_value
  end

  def ling_name
    ling.name
  end

  def ling_name_for_depth(given_depth)
    ling_name if given_depth == ling.depth
  end

  def parent_name
    ling.parent.try(:name)
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

  private

  def association_depth_match
    errors[:base] << "Must choose #{group.ling_name_for_depth(ling.depth)} and #{group.property_name} with matching depth" if ling && property && ling.depth != property.depth
  end

  def group_association_match
    errors[:base] << "#{group.ling_name_for_depth(ling.depth).humanize} and #{group.property_name} must belong to the same group as this #{group.lings_property_name}" if (ling && property) && (ling.group != property.group || ling.group != group)
  end

  def set_property_value
    self.property_value = "#{property_id}:#{value}"
    true
  end
end
