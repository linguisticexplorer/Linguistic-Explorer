class Example < ActiveRecord::Base
  include Groupable

  belongs_to :ling
  has_many :examples_lings_properties, :dependent => :destroy
  has_many :lings_properties, :through => :examples_lings_properties
  has_many :stored_values, :as => :storable

  validates_existence_of :ling, :allow_nil => true
  validate :group_association_match

  default_scope :include => :stored_values
  scope :in_group, lambda { |group| where(:group => group) }

  def grouped_name
    (group ? group.example_name : "Example")
  end

  def group_association_match
    errors.add(:ling, "#{group.ling_name_for_depth(ling.depth)} must belong to the same group as this #{group.example_name}") if ling && (ling.group != group)
  end

  def storable_keys
    ["text"]# + self.group.storable_keys
  end

  def store_value!(key_symbol_or_string, value_string)
    key = key_symbol_or_string.to_s
    if curr = stored_values.with_key(key).first
      curr.value = value_string
    else
      StoredValue.create(:key => key, :value => value_string, :storable => self)
    end
  end

  def stored_value(key_symbol_or_string)
    key = key_symbol_or_string.to_s
    if storable_keys.include? key
      (record = stored_values.with_key(key).first).present? ? record.value : ""
    else
      nil
    end
  end
end
