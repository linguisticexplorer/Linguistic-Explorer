class Group < ActiveRecord::Base
  before_create :ensure_default_values

  validates_presence_of   :name
  validates_uniqueness_of :name
  validate :allowable_depth_maximum

  has_many :examples_lings_properties, :dependent => :destroy
  has_many :lings,                     :dependent => :destroy
  has_many :properties,                :dependent => :destroy
  has_many :lings_properties,          :dependent => :destroy
  has_many :examples,                  :dependent => :destroy
  has_many :categories,                :dependent => :destroy
  has_many :memberships,               :dependent => :destroy
  has_many :users,                     :through => :memberships

  scope :public,  where( :privacy => 'public' )
  scope :private, where( :privacy => 'private' )

  def ling_name_for_depth(depth)
    if depth > depth_maximum
      "Error: No objects for depth #{depth} exist in this group."
    elsif depth == 0
      ling0_name
    elsif depth == 1
      ling1_name
    end
  end

  def ling_names
    has_depth? ? [ling0_name, ling1_name] : [ling0_name]
  end

  def has_depth?
    depth_maximum >= 1
  end

  def allowable_depth_maximum
    errors.add(:depth_maximum, "must be either 0 or 1") if depth_maximum && !(0..1).include?(depth_maximum)
  end

  private

  def ensure_default_values
    self.depth_maximum         ||= 0
    self.privacy =             "public"         if self.privacy.blank?
    self.ling0_name =          "Ling"           if self.ling0_name.blank?
    self.ling1_name =          "Linglet"        if self.ling1_name.blank? && self.depth_maximum > 0
    self.ling1_name =          "INVALID-DEPTH"  if self.ling1_name.blank? && self.depth_maximum < 1
    self.example_name =        "Example"        if self.example_name.blank?
    self.property_name =       "Property"       if self.property_name.blank?
    self.category_name =       "Category"       if self.category_name.blank?
    self.lings_property_name = "Value"          if self.lings_property_name.blank?
    self.examples_lings_property_name = "Example Value"  if self.examples_lings_property_name.blank?
  end
end
