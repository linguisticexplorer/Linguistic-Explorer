class Role < ActiveRecord::Base
  has_and_belongs_to_many :memberships, :join_table => :memberships_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
  # attr_accessible :title, :body
end
