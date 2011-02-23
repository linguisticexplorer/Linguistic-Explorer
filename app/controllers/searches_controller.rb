class SearchesController < ApplicationController
  before_filter :load_group_from_params

  def new
    @search = Search.new(@group, params[:search])
  end

  def create
    @search = Search.new(@group, params[:search])
    # Check if search if valid
    render :results
  end
  
  def results
  end

end