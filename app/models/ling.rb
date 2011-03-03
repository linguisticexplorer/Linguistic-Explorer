class Ling < ActiveRecord::Base
  validates_presence_of :name, :depth, :group
  validates_numericality_of :depth
  validates_uniqueness_of :name, :scope => :group_id
  validates_existence_of :parent, :allow_nil => true
  validates_existence_of :group
  validate :parent_depth_check
  validate :group_association_match

  belongs_to :parent, :class_name => "Ling", :foreign_key => "parent_id", :inverse_of => :children
  has_many :children, :class_name => "Ling", :foreign_key => "parent_id", :inverse_of => :parent

  belongs_to :group
  has_many :examples
  has_many :lings_properties
  has_many :properties, :through => :lings_properties

  scope :in_group, lambda { |group| where(:group => group) }
  scope :at_depth, lambda { |depth| where(:depth => depth) }

  scope :parent_ids, select("#{self.table_name}.parent_id")

  DEPTHS = [
    PARENT = 0,
    CHILD  = 1
  ]

  def add_property(value, property)
    params = {:property_id => property.id, :value => value, :group_id => group.id}
    lings_properties.create(params) unless lings_properties.exists?(params)
  end

  def parent_depth_check
    errors.add(:parent, "Depth of the parent must be one less than the child object") if (depth == 1 && parent && parent.depth != 0)
  end

  def group_association_match
    errors.add(:group, "Parent must belong to the same group as this ling") if parent && parent.group != group
  end
end
