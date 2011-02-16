class SearchesController < ApplicationController

  def new
    @search = Search.new(params[:search])
  end

  def create
    @search = Search.new(params[:search])
    render :show
  end

  def show
  end
end