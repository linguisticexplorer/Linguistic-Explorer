module LingHelper

  def sureness_color(prop)
    if @preexisting_values.any?
      lp = @preexisting_values.select{|lp| lp.property_id == prop.id}[0]
      if lp
        if lp.sureness != "revisit" && lp.sureness != "need_help"
          return "color: green";
        else
          return "color: orange";
        end
      end
    end
    return "color: red";
  end

end