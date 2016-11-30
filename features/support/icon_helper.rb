module IconHelper

  def icon_css
    @icon_css ||= {
      "Plus" => ".fa-plus",
      "Edit" => ".fa-edit",
      "Trash" => ".fa-trash-o"
    }
  end

  def have_icon icon_name
    have_css(icon_css[icon_name])
  end

  def have_no_icon icon_name
    have_no_css(icon_css[icon_name])
  end

  def page_has_icon? icon_name
    page.has_css?(icon_css[icon_name])
  end

  def page_has_no_icon? icon_name
    page.has_no_css?(icon_css[icon_name])
  end

  def icon_selector
    @icon_selector ||= {
      "group settings" => "#group_settings",
      "ling settings" => "#ling_settings",
      "property settings" => "#property_settings",
      "membership settings" => "#membership_settings",
      "edit menu" => "#edit-dropdown-menu"
    }
  end

  def get_icon_selector(selector)
    if selector.include? "actions"
      "#"+selector.downcase.tr(" ", "_")
    else
      icon_selector[selector] || selector
    end
  end

  def icon_button
    @icon_button ||= {
      "#edit-dropdown-menu" => {
        "Edit" => "edit-dropdown-button"
      }
    }
  end

  def get_icon_button(icon_name, selector)
    icon_button[selector] && icon_button[selector][icon_name] || selector
  end

end

World(IconHelper)