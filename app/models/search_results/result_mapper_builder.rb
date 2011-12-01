module SearchResults

  class ResultMapperBuilder

    attr_reader :result
    attr_accessor :strategy

    def initialize(result_adapter)
      @result = result_adapter
    end

    def self.build_result_groups(result_adapter)
      Rails.logger.debug "Step 3 => #{self.class} - Building Groups"
      kind_of_search = result_adapter.type
      groups = strategy_class_builder(kind_of_search).build_result_groups(result_adapter)
      add_type_to_groups(groups, kind_of_search)
    end

    def to_flatten_results
      @flatten_results ||= strategy_mapper_class.new(remove_type_from_result).to_flatten_results
    end

    private

    def self.add_type_to_groups(groups, type)
      groups["type"] = type.to_s unless type.eql?(:default)
      return groups
    end

    def remove_type_from_result
      @result.reject {|k,v| /type/.match(k.to_s)}
    end

    def strategy_mapper
      @strategy ||= @result["type"] || "default"
    end

    def strategy_mapper_class
      "SearchResults::Mappers::ResultMapper#{strategy_mapper.to_s.camelize}".constantize
    end

    def self.strategy_class_builder(result_type)
      "SearchResults::Mappers::ResultMapper#{result_type.to_s.camelize}".constantize
    end

  end
end