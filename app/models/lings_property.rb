class LingsProperty < ActiveRecord::Base
  belongs_to :ling
  belongs_to :property

  validates_presence_of :value, :ling_id, :property_id
#  validates_existence_of :ling#, :property
  
  def ling_name
    ling.name
  end
  
  def prop_name
    property.name
  end
end
