class SearchPresenter

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

end