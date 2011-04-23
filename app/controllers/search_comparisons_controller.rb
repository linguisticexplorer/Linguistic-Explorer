class SearchComparisonsController < GroupDataController

  def new
    @comparison = SearchComparison.new(:user => current_user, :group => current_group)
  end

  def create
    @comparison = SearchComparison.new(params[:comparison]) do |sc|
      sc.user   = current_user
      sc.group  = current_group
    end

    @search = @comparison.search

    render :template => 'searches/preview'
  end
end
