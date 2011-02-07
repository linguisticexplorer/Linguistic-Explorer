class LingsPropertySearch < Search

  def results
    conditions            = {:property_id => params[:properties]}
    conditions[:ling_id]  = params[:lings] if params[:lings]
    LingsProperty.where(conditions).includes(:property, :ling)
  end
  
end