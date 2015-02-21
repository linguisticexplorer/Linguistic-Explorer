module CSVAttributes
  # Requires class to define class method csv_attributes
  extend ActiveSupport::Concern

  module ClassMethods
    
    def importable_attributes
      csv_attributes - non_importable_attributes
    end

    def non_importable_attributes
      csv_attributes.select { |attribute| attribute =~ /id$/ }
    end
  end

  # module InstanceMethods
    def importable_attributes
      self.class.importable_attributes
    end

    def non_importable_attributes
      self.class.non_importable_attributes
    end
  # end

  def self.included(receiver)
    receiver.extend         ClassMethods
    # receiver.send :include, InstanceMethods
    # receiver.send :include
  end
end