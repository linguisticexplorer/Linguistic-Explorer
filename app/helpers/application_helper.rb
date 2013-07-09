module ApplicationHelper

  def support_email
    "support@terraling.com".html_safe
  end

  def link_to_google_web_font(font)
    "<link href='http://fonts.googleapis.com/css?family=#{u(font)}' rel='stylesheet' type='text/css'>".html_safe
  end

  def page_title
    ((content_for(:title) + " - " if content_for?(:title)).to_s + 'TerraLing').html_safe
  end

  def page_heading(text)
    content_tag(:h1, content_for(:title){ text })
  end

  def add_body_classes(*classes)
    @body_classes ||= []
    @body_classes += Array(classes).flatten
  end

  def body_classes(*additional_classes)
    classes = []
    classes << "current_user" if user_signed_in?
    classes << @body_classes if @body_classes
    classes << additional_classes
    classes.flatten.uniq.join(" - ")
  end

  # second param should return 
  def display_example(example_id, display_mode)
    example = Example.find(example_id)
    result = ""
    example.group.example_storable_keys.each do |key|
      case display_mode
      when "linguistic"
        result += example.stored_value(key) + "<br />"
      # when in default table mode
      else
        result += key.humanize + ": " + example.stored_value(key) + "<br />"
      end
    end
    return result.html_safe
  end

end
