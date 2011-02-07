class PropertySearch < Search
  
  def results
    params[:properties].present? ? Property.find(params[:properties]) : Property.all
  end
end