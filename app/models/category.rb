class Category < ActiveRecord::Base
  validates_presence_of :name, :depth, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_numericality_of :depth
  validates_existence_of :group
  validates_existence_of :creator, :allow_nil => true

  belongs_to :group
  belongs_to :creator, :class_name => "User"
  has_many :properties, :dependent => :destroy

  scope :in_group, lambda { |group| where(:group => group) }
  scope :at_depth, lambda { |depth| where(:depth => depth) }
end
