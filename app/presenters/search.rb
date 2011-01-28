class Search

  attr_accessor :ling_included, :lings
  attr_reader :lings
  
  def initialize(params = {})
    @lings = if params[:lings]
      Ling.find(params[:lings])
    else
      Ling.all
    end
  end
  
  def ling_options
    lings.map { |l| [l.name, l.id] }
  end
  
end