class Search
  def self.model_name
    "Search"
  end

  include SearchForm
  include SearchResults

  attr_reader :group

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