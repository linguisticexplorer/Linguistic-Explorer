module LingHelper

  def sureness_color(prop)
    colors = {
      :certain => "color: green;",
      :revisit => "color: orange;",
      :not_set => "color: red;"
    }
   colors[get_sureness_type(prop)]
  end

  def sureness_class(prop)
    classes = {
      :certain => "value-certain",
      :revisit => "value-revisit",
      :not_set => "value-not-set"
    }
   classes[get_sureness_type(prop)]
  end

  private

  def get_sureness_type(prop)
    if @preexisting_values.any?
      lp = @preexisting_values.select{|lp| lp.property_id == prop.id}[0]
      if lp
        if lp.sureness != "revisit" && lp.sureness != "need_help"
          return :certain;
        else
          return :revisit;
        end
      end
    end
    return :not_set;
  end

end