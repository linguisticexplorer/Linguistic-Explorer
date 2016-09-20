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
      # This shows a NO_DEPTH_1_RESULT as result if no result is retrieved     #
      # in depth 1 search.                                                     #
      ##########################################################################
      is_depth_0?(depth) & any_error?(result) ? [] : result
    end

  end

  class KeywordStrategy

    def initialize(filter, query)
      @filter, @query = filter, query
    end

    def query_key
      "#{model_name}_keywords".to_sym
    end

    def model_name
      "#{model_class.name.downcase.underscorize}"
    end

    def keyword(depth)
      @query[query_key] && @query[query_key][depth.to_s]
    end

    def group
      @query.group
    end

    def vals_at(depth)
      vals = @filter.vals_at(depth)
      keyword(depth).present? ? select_vals_by_keyword(vals, keyword(depth)) : vals
    end

    def select_vals_by_keyword(vals, keyword)
      result = LingsProperty.select_ids.
        # where(:id => vals.pluck(:id)).
        with_id(vals.pluck(:id)).
        # includes(:ling, :property, :examples).
        joins("#{model_name}".to_sym).
        # Intersect with the result of keyword search
        merge search_scope_name_by_keyword(keyword)
      
      # p "[DEBUG] #{result.inspect}"
      result.empty? ? Filter::NO_DEPTH_1_RESULT : result
    end

    def search_scope_name_by_keyword(keyword)
      model_class.in_group(group).unscoped.
      # Arel
        where( (model_class.arel_table[:name].matches("#{keyword}%")).
        or( model_class.arel_table[:name].matches("%#{keyword}%") ))
      # Metawhere
          # where({:name.matches  => "#{keyword}%"} | { :name.matches => "%#{keyword}%"})
      # Squeel Syntax
      #     where{ (:name =~  "#{keyword}%") || ( :name =~ "%#{keyword}%")}
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
      @query[query_key] && @query[query_key][category_id.to_s]
    end

    def map_selected_vals_id(selected_vals)
      selected_vals == Filter::NO_DEPTH_1_RESULT ? [-1] : selected_vals.map(&:id)
    end

    def vals_at(depth)
      vals          = @filter.vals_at(depth)
      category_ids  = @query.group_prop_category_ids(depth)

      collected_ids = category_ids.collect do |category_id|
        if keyword(category_id).present?
          map_selected_vals_id(select_vals_by_keyword(vals, keyword(category_id)))
        else
          raise Exceptions::ResultTooBigError if vals.size > Search::RESULTS_FLATTEN_THRESHOLD
          map_selected_vals_id(vals)
        end
      end.flatten

      return collected_ids if collected_ids == Filter::NO_DEPTH_1_RESULT
      LingsProperty.with_id(collected_ids).select_ids
    end

  end

  class ExampleKeywordStrategy < KeywordStrategy
    # query: :example_fields=>{"0"=>["origin"], "1"=>["text"]}, :example_keywords=>{"0"=>"gold", "1"=>""}}

    def model_class
      Example
    end

    def keyword(depth)
      @query[query_key] && @query[query_key][depth.to_s]
    end

    def vals_at(depth)
      vals = @filter.vals_at(depth)
      keyword(depth).present? ? select_vals_by_keyword(vals, keyword(depth), depth) : vals
    end

    def select_vals_by_keyword(vals, keyword, depth)
      example_attribute = @query[:example_fields][depth.to_s].to_sym
      keyword_scope = case example_attribute
                        when :description
                          search_scope_name_by_keyword(keyword)
                        else
                          # keyword search by stored value key/pair
                          search_scope_value_by_stored_value_key_pair(keyword, example_attribute)
                      end
      
      LingsProperty.select_ids.where(:id => vals.pluck(:id)).
        joins(:examples).merge keyword_scope
      # Squeel Syntax
      # LingsProperty.select_ids.where{ (:id == my{vals}) } & keyword_scope
    end

    def search_scope_value_by_stored_value_key_pair(keyword, key)
      model_class.unscoped.where(:group_id => group.id).

        joins("INNER JOIN stored_values ON examples.id = stored_values.storable_id").
        merge  StoredValue.unscoped.with_key(key).

        where( (StoredValue.arel_table[:value].matches("#{keyword}%")).
        or(StoredValue.arel_table[:value].matches("%#{keyword}%") ))
      #  Squeel Syntax
      # model_class.unscoped.where{ :group == my{group.id} } &
      #   StoredValue.unscoped.with_key(key).
      #   where { (:value =~ "#{keyword}%") || (:value =~ "%#{keyword}%")}
    end

  end

end
