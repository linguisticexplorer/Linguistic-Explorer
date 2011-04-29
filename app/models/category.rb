class Category < ActiveRecord::Base
  include Groupable

  validates_presence_of :name, :depth
  validates_uniqueness_of :name, :scope => :group_id
  validates_numericality_of :depth
  validate :depth_for_group

  has_many :properties, :dependent => :destroy

  include Concerns::Wheres
  include Concerns::Selects

  def self.ids_by_group_and_depth(group, depth)
    in_group(group).at_depth(depth).map(&:id)
  end

  def depth_for_group
    errors.add(:depth, "is deeper than allowed in #{group.name}") if group && depth && group.depth_maximum < depth
  end
end
