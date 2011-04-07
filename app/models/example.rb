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
end
