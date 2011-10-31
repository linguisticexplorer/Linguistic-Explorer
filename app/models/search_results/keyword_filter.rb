module SearchResults

  class KeywordFilter < Filter
    attr_accessor :strategy

    def initialize(filter, query)
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
      @filter_strategy_instance ||= strategy_class.new(@filter, @query)
      result = @filter_strategy_instance.vals_at(depth)

      ##########################################################################
      # Trick to solve issue #1                                                #
      # This shows an empty result if no entry has found on depth 0 if         #
      # NO_DEPTH_1_RESULT retrieved                                            #
      ##########################################################################
      is_depth_0?(depth) & any_error?(result) ? [] : result
    end

  end

  class KeywordStrategy

    def initialize(filter, query)
      @filter, @query = filter, query
    end

    def query_key
      "#{model_class.name.downcase.underscorize}_keywords".to_sym
    end

    def keyword(depth)
      @query[query_key][depth.to_s]
    end

    def group
      @query.group
    end

    def vals_at(depth)
      vals = @filter.vals_at(depth)
      keyword(depth).present? ? select_vals_by_keyword(vals, keyword(depth)) : vals
    end

    def select_vals_by_keyword(vals, keyword)
      result = LingsProperty.select_ids.where(:id => vals) & search_scope_name_by_keyword(keyword)

      result.empty? ? Filter::NO_DEPTH_1_RESULT : result
    end

    def search_scope_name_by_keyword(keyword)
      model_class.in_group(group).unscoped.
          where({:name.matches => "#{keyword}%"} | { :name.matches => "%#{keyword}%"})
    end

  end

  class LingKeywordStrategy < KeywordStrategy

    def model_class
      Ling
    end

  end

  class PropertyKeywordStrategy < KeywordStrategy

    def model_class
      Property
    end

    def keyword(category_id)
      @query[query_key][category_id.to_s]
    end

    def vals_at(depth)
      vals          = @filter.vals_at(depth)
      category_ids  = @query.group_prop_category_ids(depth)

      category_ids.collect do |category_id|
        if keyword(category_id).present?
          select_vals_by_keyword(vals, keyword(category_id))
        else
          raise Exceptions::ResultTooBigError if vals.size > Search::RESULTS_FLATTEN_THRESHOLD
          vals
        end
      end.flatten
    end

  end

  class ExampleKeywordStrategy < KeywordStrategy
    # query: :example_fields=>{"0"=>["origin"], "1"=>["text"]}, :example_keywords=>{"0"=>"gold", "1"=>""}}

    def model_class
      Example
    end

    def keyword(depth)
      @query[query_key][depth.to_s]
    end

    def vals_at(depth)
      vals = @filter.vals_at(depth)
      keyword(depth).present? ? select_vals_by_keyword(vals, keyword(depth), depth) : vals
    end

    def select_vals_by_keyword(vals, keyword, depth)
      example_attribute = @query[:example_fields][depth.to_s].to_sym
      keyword_scope = case example_attribute
                        when :text
                          search_scope_name_by_keyword(keyword)
                        else
                          # keyword search by stored value key/pair
                          search_scope_value_by_stored_value_key_pair(keyword, example_attribute)
                      end

      LingsProperty.select_ids.where(:id => vals) & keyword_scope
    end

    def search_scope_value_by_stored_value_key_pair(keyword, key)
      model_class.unscoped.where(:group_id => group.id) &
        StoredValue.unscoped.with_key(key).
        where({:value.matches => "#{keyword}%"} | { :value.matches => "%#{keyword}%"})
    end

  end

end
