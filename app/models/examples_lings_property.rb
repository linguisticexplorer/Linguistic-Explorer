class ExamplesLingsProperty < ActiveRecord::Base
  include Groupable
  include CSVAttributes

  CSV_ATTRIBUTES = %w[ id example_id lings_property_id group_id creator_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  # validates_presence_of :example, :lings_property
  # validates_existence_of :example, :lings_property
  validates :example, :lings_property, :presence => true, :existence => true
  validates :example_id, :uniqueness => { :scope => :lings_property_id }
  # validates_uniqueness_of :example_id, :scope => :lings_property_id
  validate :associated_ling_match
  validate :group_association_match

  belongs_to :example
  belongs_to :lings_property

  def associated_ling_match
    errors[:base] << "#{group.example_name} and #{group.lings_property_name} must both be related to the same #{group.ling_names.join(" or ")}" if group && example && lings_property && example.ling && example.ling != lings_property.ling
  end

  def group_association_match
    errors[:base] << "#{group.example_name} and #{group.lings_property_name} must belong to the same group as this #{group.examples_lings_property_name}" if (example && lings_property && group) && (example.group != lings_property.group || example.group != group)
  end

  def get_valid_resource
    lings_property.ling
  end
end
