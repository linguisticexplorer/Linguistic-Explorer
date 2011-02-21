class String
  def underscorize
    downcase.gsub(" ", "_")
  end
end