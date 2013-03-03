module Concerns
  module Wheres
    def self.included(base)
      base.class_exec do
        scope :in_group, lambda { |group| where{ :group == group } }
        scope :at_depth, lambda { |depth| where{ :depth == depth } }
      end
    end
  end
end
