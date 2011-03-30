module SearchResults

  class KeywordFilter < Filter
    attr_accessor :strategy

    def initialize(filter, params)
      super
      yield self if block_given?
    end

    def strategy
      @strategy ||= :ling
    end

    def depth_0_vals
      @depth_0_vals ||= filter_vals(Depth::PARENT)
    end

    def depth_1_vals
      @depth_1_vals ||= filter_vals(Depth::CHILD)
    end

    private

    def strategy_class
      "SearchResults::#{@strategy.to_s.camelize}KeywordStrategy".constantize
    end

    def filter_vals(depth)
      @filter_strategy_instance ||= strategy_class.new(@filter, @params)
      @filter_strategy_instance.vals_at(depth)
    end

  end

  class KeywordStrategy
    def initialize(filter, params)
      @filter, @params = filter, params
    end

    def params_key
      "#{model_class.name.downcase.underscorize}_keywords".to_sym
    end

    def select_vals_by_keyword(vals, keyword)
      LingsProperty.select_ids.where(:id => vals) & model_class.where(:name.matches => "#{keyword}%")
    end
  end

  class LingKeywordStrategy < KeywordStrategy

    def model_class
      Ling
    end

    def keyword(depth)
      @params[params_key][depth.to_s]
    end

    def vals_at(depth)
      vals = @filter.vals_at(depth)
      keyword(depth).present? ? select_vals_by_keyword(vals, keyword(depth)) : vals
    end

  end

  class PropertyKeywordStrategy < KeywordStrategy

    def model_class
      Property
    end

    def keyword(category_id)
      @params[params_key][category_id.to_s]
    end

    def vals_at(depth)
      vals          = @filter.vals_at(depth)
      category_ids  = @params.group_prop_category_ids(depth)
      category_ids.collect do |category_id|
        keyword(category_id).present? ? select_vals_by_keyword(vals, keyword(category_id)) : vals
      end.flatten
    end

  end

end