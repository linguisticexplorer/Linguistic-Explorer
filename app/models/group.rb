class Group < ActiveRecord::Base
  before_create :ensure_default_values

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :lings
  has_many :properties
  has_many :lings_properties
  has_many :examples
  has_many :categories

  private

  def ensure_default_values
    self.ling0_name =           "Ling"           if self.ling0_name.blank?
    self.ling1_name =           "Linglet"        if self.ling1_name.blank?
    self.property_name =        "Property"       if self.property_name.blank?
    self.category_name =        "Category"       if self.category_name.blank?
    self.lings_property_name =  "Value"          if self.lings_property_name.blank?
    self.example_name =         "Example"        if self.example_name.blank?
    self.example_lp_name =      "Example Value"  if self.example_lp_name.blank?
    self.privacy =              "public"         if self.privacy.blank?
    self.depth_maximum          ||= 1
  end
end
