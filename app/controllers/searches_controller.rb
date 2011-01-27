class SearchesController < ApplicationController
  
  def new
    @search = Search.new
  end
end