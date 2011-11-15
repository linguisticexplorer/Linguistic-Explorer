module SearchResults

  class ResultMapper

    attr_reader :result_groups

    def initialize(results)
      @result_groups = results
    end

    def all_child_ids
      result_groups.values
    end

    def parent_ids
      result_groups.keys
    end

    class ResultEntry
      attr_reader :parent, :child

      def initialize(parent, child=nil)
        @parent, @child = parent, child
      end

    end
  end
end