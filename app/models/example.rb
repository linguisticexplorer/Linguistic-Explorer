class Example < ActiveRecord::Base
  include Groupable

  validates_existence_of :ling, :allow_nil => true
  validate :group_association_match

  belongs_to :ling
  has_many :examples_lings_properties, :dependent => :destroy
  has_many :lings_properties, :through => :examples_lings_properties

  scope :in_group, lambda { |group| where(:group => group) }

  def group_association_match
    errors.add(:ling, "#{group.ling_name_for_depth(ling.depth)} must belong to the same group as this #{group.example_name}") if ling && (ling.group != group)
  end

#  has_many :stored_values, :as => :storable
#
#  def storable_keys
#    self.group.storable_keys + ["text"]
#  end
#
#  def store_value!(key_symbol_or_string, value_string)
#    key = key_symbol_or_string.to_s
#    curr = self.stored_values.with_key(key)
#    if curr
#      curr.value = value_string
#    else
#      StoredValue.create(:key => key, :value => value_string, :storable => self)
#    end
#  end
#
#  def stored_value(key_symbol_or_string)
#    key = key_symbol_or_string.to_s
#    if storable_keys.include? key
#      "foo"
#    else
#      nil
#    end
#  end
end
