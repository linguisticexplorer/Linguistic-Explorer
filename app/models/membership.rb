class Membership < ActiveRecord::Base
  rolify
  include CSVAttributes

  ACCESS_LEVELS = [
    ADMIN = "admin",
    MEMBER = "member"
  ]

  ROLES = [
    EXPERT  = "expert"
  ]

  CSV_ATTRIBUTES = %w[ id member_id group_id level creator_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  include Groupable

  # validates_presence_of :member, :level
  # validates_existence_of :member
  validates :member, :presence => true, :existence => true
  validates :level, :presence => true
  # validates_uniqueness_of :member_id, :scope => :group_id
  validates :member_id, :uniqueness => {:scope => :group_id }
  validates_inclusion_of :level, :in => ACCESS_LEVELS

  belongs_to :member, :class_name => "User", :foreign_key => :member_id

  def group_admin?
    ADMIN == level
  end

  # Avoid global role for now
  def add_expertise_in(instance)
    grant :expert, instance if instance.present?
  end

  def remove_expertise_in(instance)
    revoke :expert, instance if instance.present?
  end

  def set_expertise_in(instances)
    # check instances and sort them
    current_resources = self.roles.sort.map(&:resource)
    # sort incoming instances as well
    new_resources = instances.sort

    # remove roles not present in the new set
    current_resources.each do |resource|
      unless new_resources.include? resource
        remove_expertise_in resource
      end
    end

    # add resources present only in the new set and not in the old one
    new_resources.each do |resource|
      unless current_resources.include? resource
        add_expertise_in resource
      end
    end
  end

  def role
    level === ADMIN ? 'group admin' :
      is_expert? ? 'expert' : MEMBER
  end

  def is_expert?
    # Due to a bug (issue #230) for unsaved models it need to check also for the roles array size...
    self.has_role?(:expert, :any) && self.roles.count > 0
  end

  def as_json(options={})
    super(
      :only => [:id, :group_id, :level, :creator_id],
      :include => {
        :member => {
          :only => [:id, :name, :email]
        }
      }
    )
  end

  # This method is used to extract the ling and discover if the user is expert of that ling.
  # Expert can't manage the membership and return the membership is a error
  def get_valid_resource
    false
  end

end
