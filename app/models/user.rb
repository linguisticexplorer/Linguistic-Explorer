class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name, :email, :access_level

  has_many :group_memberships, :dependent => :destroy
  has_many :groups, :through => :group_memberships

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :password, :password_confirmation, :remember_me

  def admin?
    "admin" == self.access_level
  end
end
