class Role < ActiveRecord::Base
  has_and_belongs_to_many :memberships, :join_table => :memberships_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
  
  validates :name, :presence => true
  validates_inclusion_of :name, :in => Membership::ROLES
end
