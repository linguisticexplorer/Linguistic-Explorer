class Search
  include SearchForm
  include SearchResults

  def initialize(group, params)
    @group  = group
    @params = params
  end

  def show?(search_type)
    # TODO Not checking "Include" option to show yet
    # show_param[search_type].present?
    true
  end

end