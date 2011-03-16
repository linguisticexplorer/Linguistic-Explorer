module Extensions
  module Orders
    def self.included(base)
      base.class_exec do
        scope :order_by_name, order("#{self.table_name}.name")
      end
    end
  end
end