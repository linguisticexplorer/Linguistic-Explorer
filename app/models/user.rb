class User < ActiveRecord::Base
  include CSVAttributes
  include Humanizer

  ACCESS_LEVELS = [
      ADMIN = "admin",
      USER  = "user"
  ]

  CSV_ATTRIBUTES = %w[ id name email access_level password ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  attr_accessor :bypass_humanizer
  
  #TODO: Remove this trick 
  # Until we migrate to rspec 2.6, use this trick...
  # if Rails.env.production?
  #   require_human_on :create, :unless => :bypass_humanizer
  # end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name, :email, :access_level

  has_many :memberships, :foreign_key => :member_id, :dependent => :destroy
  has_many :searches, :foreign_key=> :creator_id, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :topics, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :humanizer_question_id, :humanizer_answer

  def admin?
    ADMIN == self.access_level
  end

  def administrated_groups
    self.memberships.select{ |m| m.group_admin? }.map(&:group)
  end

  def reached_max_search_limit?(group)
    Search.reached_max_limit?(self, group)
  end

  def member_of?(group)
    group.is_a?(Group) && group_ids.include?(group.id)
  end

  def group_admin_of?(group)
    group.membership_for(self).try(:group_admin?)
  end

  def is_expert_of?(resource)
    return true if admin?
    ling, group = get_ling_and_group resource
    return true if self.group_admin_of?(group)

    # resource_ids_for_role :resource_expert, resource
    if ling && member_of?(group) && is_expert?(group)

      # is thruthy if either is assigned to that resource or
      # the resource has nobody set as expert for the moment
      return group.membership_for(self).has_role?(:expert, ling) || has_no_expert(ling)
    end

  end

  def is_expert?(group)
    group.membership_for(self).try(:is_expert?)
  end

  def is_expert_for_groups
    [].tap do |entry|
      memberships.each do |membership|
        entry << membership.group.id if membership.is_expert?
      end
    end
  end

  def fake_password

  end

  def as_json(options={})
    super(:only => [:id, :name, :email])
  end

  private

  def get_ling_and_group(resource)

    # # get referenced Ling
    # ling = resource.is_a?(Ling) ? resource : 
    #        resource.try(:ling)
    # valid_type = [Ling, LingsProperty, ExamplesLingsProperty]
    # valid_resource = resource.is_a?(*valid_type) ? resource.get_valid_resource : false
    # [valid_resource, resource.is_a?(Group) ? resource : resource.group]
    [resource.get_valid_resource || false, resource.is_a?(Group) ? resource : resource.group]
  end

  def has_no_expert(resource)
    resource.roles.empty?
  end

end
