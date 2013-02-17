module Concerns
  module Wheres
    def self.included(base)
      base.class_exec do
        scope :in_group, lambda { |group| where(:group_id => group.id) }
        scope :at_depth, lambda { |depth| where(:depth => depth) }
      end
    end
  end
end
