class Group < ActiveRecord::Base
  PRIVACY = [
    PRIVATE = 'private',
    PUBLIC  = 'public'
  ]
  MAXIMUM_ASSIGNABLE_DEPTH = 1
  DEFAULT_EXAMPLE_KEYS = ["text"]
  DEFAULTS = {
        :depth_maximum  => MAXIMUM_ASSIGNABLE_DEPTH,
        :privacy        => PUBLIC,
        :ling0_name     => "Ling",
        :ling1_name     => "Linglet",
        :example_name   => "Example",
        :property_name  => "Property",
        :category_name  => "Category",
        :lings_property_name => "Value",
        :examples_lings_property_name => "Example Value"
  }

  validates_presence_of     :name
  validates_uniqueness_of   :name
  validates_numericality_of :depth_maximum, :<= => MAXIMUM_ASSIGNABLE_DEPTH
  validates_inclusion_of    :privacy,       :in => PRIVACY

  has_many :examples_lings_properties, :dependent => :destroy
  has_many :lings,                     :dependent => :destroy
  has_many :properties,                :dependent => :destroy
  has_many :lings_properties,          :dependent => :destroy
  has_many :examples,                  :dependent => :destroy
  has_many :categories,                :dependent => :destroy
  has_many :memberships,               :dependent => :destroy
  has_many :members,                   :through => :memberships, :source => :member

  scope :public,  where( :privacy => PUBLIC )
  scope :private, where( :privacy => PRIVATE )

  def ling_name_for_depth(depth)
    if depth > depth_maximum
      raise Exception.new "The ling depth requested was too deep for the group."
    else
      ling_names[depth.to_i]
    end
  end

  def ling_names
    has_depth? ? [ling0_name, ling1_name] : [ling0_name]
  end

  def has_depth?
    depth_maximum >= 1
  end

  def depths
    (0..depth_maximum).to_a
  end

  def example_storable_keys
    (DEFAULT_EXAMPLE_KEYS + (!example_fields.blank? ? example_fields.split(",").collect(&:strip) : [])).uniq
  end

  def private?
    PRIVATE == privacy
  end

  def membership_for(user)
    memberships.where(:member_id => user.id)
end
end
