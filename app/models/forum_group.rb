class ForumGroup < ActiveRecord::Base
  
  # Associations
  has_many :forums, :dependent => :destroy
  
  # Accessors
  attr_accessible :title, :state, :position, :forum_group_id
  
  # Scopes
  default_scope :order => 'position ASC'
  
  # Validations
  validates :title,       :presence => true
end