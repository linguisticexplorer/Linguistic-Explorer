class Property < ActiveRecord::Base
  include Groupable
  include CSVAttributes

  CSV_ATTRIBUTES = %w[ id name description category_id group_id creator_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  validates_presence_of :name, :category
  validates_uniqueness_of :name, :scope => :group_id
  validates_existence_of :category
  validate :group_association_match

  belongs_to :category
  belongs_to :creator, :class_name => "User"
  has_many :lings_properties, :dependent => :destroy

  include Concerns::Selects
  include Concerns::Wheres
  include Concerns::Orders

  # override
  scope :at_depth, lambda { |depth| scoped & Category.at_depth(depth) }

  def depth
    category.depth
  end

  def available_values
    lings_properties.map(&:value).uniq
  end

  def group_association_match
    errors.add(:category, "#{group.category_name.humanize} must belong to the same group as this #{group.property_name}") if group && category && category.group != group
  end
end
