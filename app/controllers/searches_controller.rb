class SearchesController < ApplicationController
  
  def new
    @search = Search.factory
  end
  
  def create
    @search = Search.factory(params[:search])
    render :show
  end
  
  def show
  end
end