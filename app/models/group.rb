class Group < ActiveRecord::Base
  before_create :ensure_default_values

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :lings, :dependent => :destroy
  has_many :properties, :dependent => :destroy
  has_many :lings_properties, :dependent => :destroy
  has_many :examples, :dependent => :destroy
  has_many :categories, :dependent => :destroy

  has_many :group_memberships, :dependent => :destroy
  has_many :users, :through => :group_memberships

  def ling_name_for_depth(depth)
    if depth > depth_maximum
      "Error: No objects for depth #{depth} exist in this group."
    elsif depth == 0
      ling0_name
    elsif depth == 1
      ling1_name
    end
  end
  
  def has_depth?
    depth_maximum >= 1
  end

  private

  def ensure_default_values
    self.depth_maximum          ||= 0
    self.ling0_name =           "Ling"           if self.ling0_name.blank?
    self.ling1_name =           "Linglet"        if self.ling1_name.blank? && self.depth_maximum > 0
    self.ling1_name =           nil              if self.ling1_name.blank? && self.depth_maximum <= 0
    self.property_name =        "Property"       if self.property_name.blank?
    self.category_name =        "Category"       if self.category_name.blank?
    self.lings_property_name =  "Value"          if self.lings_property_name.blank?
    self.example_name =         "Example"        if self.example_name.blank?
    self.example_lp_name =      "Example Value"  if self.example_lp_name.blank?
    self.privacy =              "public"         if self.privacy.blank?
  end
end
