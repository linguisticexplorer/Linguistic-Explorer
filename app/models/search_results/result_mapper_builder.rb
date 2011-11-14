module SearchResults

  class ResultMapperBuilder

    attr_reader :result
    attr_accessor :strategy

    def initialize(result_adapter)
      @result = result_adapter
    end

    def to_flatten_results
      @flatten_results ||= strategy_class.new(remove_type_from_result).to_flatten_results
    end

    private

    def remove_type_from_result
      @result.select {|k,v| !/type/.match(k.to_s)}
    end

    def strategy
      @strategy ||= @result["type"] || "default"
    end

    def strategy_class
      "SearchResults::ResultMapper#{strategy.to_s.camelize}".constantize
    end

    def self.build_result_groups(result_adapter)
      result = case result_adapter.type
                 when :cross
                   cross_builder(result_adapter).build_result_groups
                 else
                   default_builder(result_adapter).build_result_groups
               end
      result["type"] = result_adapter.type.to_s
      result
    end


    def self.cross_builder(result)
      CrossGroupsBuilder.new(result)
    end

    def self.default_builder(result)
      DefaultGroupsBuilder.new(result)
    end

  end

  class GroupsBuilder

      attr_reader :result

      def initialize(result)
        @result = result
      end

      def parent_ids
        @result.parent
      end

      def child_ids
        @result.child
      end

      def columns
        @result.columns
      end

      def empty_result
        {}
      end

      def is_parent?(depth)
        depth == Depth::PARENT
      end

      def klass
        /Default|Cross/.match(self.class.name)[0].constantize
      end

      def vals_by_property_id(vals)
        vals.group_by { |v| v.property_id }
      end

    end
end