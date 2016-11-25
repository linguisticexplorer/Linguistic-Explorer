def icon_css icon_name
  icons = {
    "Plus" => ".fa-plus",
    "Edit" => ".fa-edit",
    "Trash" => ".fa-trash-o"
  }
  icons[icon_name]
end

def have_icon icon_name
  have_css(icon_css(icon_name))
end

def have_no_icon icon_name
  have_no_css(icon_css(icon_name))
end

def page_has_icon? icon_name
  page.has_css?(icon_css(icon_name))
end

def page_has_no_icon? icon_name
  page.has_no_css?(icon_css(icon_name))
end