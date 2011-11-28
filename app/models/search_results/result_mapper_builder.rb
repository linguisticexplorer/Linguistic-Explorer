module SearchResults

  class ResultMapperBuilder

    attr_reader :result
    attr_accessor :strategy

    def initialize(result_adapter)
      @result = result_adapter
    end

    def self.build_result_groups(result_adapter)
      Rails.logger.debug "Step 3 => #{self.class} - Building Groups"
      strategy_class_builder(result_adapter.type).build_result_groups(result_adapter)
    end

    def to_flatten_results
      @flatten_results ||= strategy_mapper_class.new(remove_type_from_result).to_flatten_results
    end

    private

    def remove_type_from_result
      @result.reject {|k,v| /type/.match(k.to_s)}
    end

    def strategy_mapper
      @strategy ||= @result["type"] || "default"
    end

    def strategy_mapper_class
      "SearchResults::Mappers::ResultMapper#{strategy_mapper.to_s.camelize}".constantize
    end

    def self.strategy_builder(result_type)
      result_type || :default
    end

    def self.strategy_class_builder(result_type)
      "SearchResults::Mappers::ResultMapper#{result_type.to_s.camelize}".constantize
    end

  end
end