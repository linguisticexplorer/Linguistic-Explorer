class Property < ActiveRecord::Base
  validates_presence_of :name, :category, :depth, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_numericality_of :depth
  validates_existence_of :group

  belongs_to :group
  has_many :lings_properties
  
  scope :in_group, lambda { |group| where(:group => group) }
  scope :at_depth, lambda { |depth| where(:depth => depth) }
end
