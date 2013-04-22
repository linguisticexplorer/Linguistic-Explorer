class LingsProperty < ActiveRecord::Base
  include Groupable
  include CSVAttributes

  CSV_ATTRIBUTES = %w[ id ling_id property_id value group_id creator_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  # validates_presence_of :value, :property, :ling
  # validates_existence_of :ling, :property
  # validates_uniqueness_of :value, :scope => [:ling_id, :property_id]
  validates :ling, :presence => true, :existence => true
  validates :property, :presence => true, :existence => true
  validates :value, :presence => true, :uniqueness => { :scope => [:ling_id, :property_id] }
  validate :association_depth_match
  validate :group_association_match

  belongs_to :ling
  belongs_to :property
  has_one    :category, :through => :property

  has_many :examples_lings_properties, :dependent => :destroy
  has_many :examples, :through => :examples_lings_properties

  before_save  :set_property_value

  include Concerns::Selects
  include Concerns::Wheres

  scope :ling_ids, select("#{self.table_name}.ling_id")
  scope :prop_ids, select("#{self.table_name}.property_id")
  scope :property_value, select("#{self.table_name}.property_value")

  scope :with_id, lambda { |id_or_ids| where("#{self.table_name}.id" => id_or_ids) }
  scope :with_ling_id, lambda { |id_or_ids| where("#{self.table_name}.ling_id" => id_or_ids) }

  scope :property_relatives, lambda { |prop_id| join(:lings).where("#{self.table_name}.property_id") }

  def self.group_by_statement
    LingsProperty.column_names.map { |c| "lings_properties.#{c}"}.join(", ")
  end

  def self.select_ids
    ids.ling_ids.prop_ids.property_value
  end

  def ling_name
    # If a Ling has a symbol at the beginning don't capitalize
    return ling.name if(ling.name =~/^(\\|=)/) 
    ling.name.capitalize
  end

  def parent_name
    ling.parent.try(:name)
  end

  def prop_name
    property.name
  end

  def prop_id
    property_id
  end

  def category_id
    property.category_id
  end

  def parent_ling_id
    ling.parent_id
  end

  def column_map(attrs)
    [].tap do |cols|
      cols << self.id
      attrs.each do |attribute|
        cols << self.send(attribute)
      end
    end
  end

  def description
    return "#{ling_name} - #{prop_name} : #{value}"if(ling.present? && property.present?)
    property_value ? "#{property_value}" : ''
  end

  private

  def association_depth_match
    errors[:base] << "Must choose #{ling.grouped_name} and #{group.property_name} with matching depth" if ling && property && ling.depth != property.depth
  end

  def group_association_match
    errors[:base] << "#{ling.grouped_name.humanize} and #{group.property_name} must belong to the same group as this #{group.lings_property_name}" if (ling && property) && (ling.group != property.group || ling.group != group) && group.present?
  end

  def set_property_value
    self.property_value = "#{property_id}:#{value}"
    true
  end

end
