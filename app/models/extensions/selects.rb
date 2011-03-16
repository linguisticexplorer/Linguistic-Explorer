module Extensions
  module Selects
    def self.included(base)
      base.class_exec do
        scope :ids, select("#{self.table_name}.id")
      end
    end
  end
end