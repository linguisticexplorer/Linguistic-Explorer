class Category < ActiveRecord::Base
  validates_presence_of :name, :depth, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_numericality_of :depth
  validates_existence_of :group
  validates_existence_of :creator, :allow_nil => true

  belongs_to :group
  belongs_to :creator, :class_name => "User"
  has_many :properties, :dependent => :destroy

  include Extensions::Wheres
  include Extensions::Selects

  def self.ids_by_group_and_depth(group, depth)
    in_group(group).at_depth(depth).map(&:id)
  end
end
