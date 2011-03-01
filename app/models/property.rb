class Property < ActiveRecord::Base
  validates_presence_of :name, :category, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_existence_of :group, :category

  belongs_to :group
  belongs_to :category
  has_many :lings_properties

  scope :in_group, lambda { |group| where(:group => group) }
  scope :at_depth, lambda { |depth| joins(:category).where("categories.depth" => depth) }

  def depth
    category.depth
  end
end
