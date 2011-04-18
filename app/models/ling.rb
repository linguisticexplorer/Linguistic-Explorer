class Ling < ActiveRecord::Base
  include Groupable

  validates_presence_of :name, :depth
  validates_numericality_of :depth
  validates_uniqueness_of :name, :scope => :group_id
  validates_existence_of :parent, :allow_nil => true
  validate :parent_depth_check
  validate :group_association_match
  validate :available_depth_for_group

  # TODO dependent nullify parent_id on child if parent destroyed
  belongs_to :parent, :class_name => "Ling", :foreign_key => "parent_id", :inverse_of => :children
  has_many :children, :class_name => "Ling", :foreign_key => "parent_id", :inverse_of => :parent

  has_many :examples, :dependent => :destroy
  has_many :lings_properties, :dependent => :destroy
  has_many :properties, :through => :lings_properties

  include Extensions::Wheres
  include Extensions::Selects
  include Extensions::Orders

  attr_protected :depth

  scope :parent_ids, select("#{self.table_name}.parent_id")
  scope :with_parent_id, lambda { |id_or_ids| where("#{self.table_name}.parent_id" => id_or_ids) }

  def grouped_name
    group.ling_name_for_depth(self.depth || 0)
  end

  def add_property(value, property)
    params = {:property_id => property.id, :value => value, :group_id => group.id}
    lings_properties.create(params) unless lings_properties.exists?(params)
  end

  def parent_depth_check
    errors.add(:parent, "must be a #{group.ling0_name.humanize} object") if (depth == 1 && parent && parent.depth != 0)
  end

  def group_association_match
    errors.add(:parent, "#{group.ling0_name.humanize} must belong to the same group as this #{self.grouped_name}") if parent && parent.group != group
  end

  def available_depth_for_group
    errors.add(:depth, "is deeper than allowed in #{group.name}") if group && depth && group.depth_maximum < depth
  end
end
