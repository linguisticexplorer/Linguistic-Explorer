module SearchResults

  class LingsKeywordFilter < Filter

    def depth_0_vals
      @depth_0_vals ||= filter_vals(Depth::PARENT)
    end

    def depth_1_vals
      @depth_1_vals ||= filter_vals(Depth::CHILD)
    end

    private

    def filter_vals(depth)
      vals    = @filter.vals_at(depth)
      keyword = @params[:lings_keywords][depth.to_s]
      keyword.present? ? select_vals_by_keyword(vals, keyword) : vals
    end

    def select_vals_by_keyword(vals, keyword)
      LingsProperty.select_ids.where(:id => vals) & Ling.where(:name.matches => "#{keyword}%")
    end

  end

end
