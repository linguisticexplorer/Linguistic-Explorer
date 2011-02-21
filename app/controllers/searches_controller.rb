class SearchesController < ApplicationController
  before_filter :load_group_from_params

  def new
    @search = Search.new(@group, params[:search])
  end

  def create
    @search = Search.new(@group, params[:search])
    render :show
  end

  def show
  end
end