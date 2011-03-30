class Category < ActiveRecord::Base
  include Groupable

  validates_presence_of :name, :depth
  validates_uniqueness_of :name, :scope => :group_id
  validates_numericality_of :depth

  has_many :properties, :dependent => :destroy

  include Extensions::Wheres
  include Extensions::Selects

  def self.ids_by_group_and_depth(group, depth)
    in_group(group).at_depth(depth).map(&:id)
  end
end
