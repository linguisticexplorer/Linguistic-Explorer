class LingsProperty < ActiveRecord::Base
  include ActiveModel::Validations

  validates_presence_of :value, :property_id, :ling_id
  validates_existence_of :ling, :property

  belongs_to :ling
  belongs_to :property

  def ling_name
    ling.name
  end
  
  def prop_name
    property.name
  end
end
