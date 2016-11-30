Then /^(?:|I )should see "([^\"]*)" icon on the "?([^\"]*)"?$/ do |icon_name, selector|
  selector = get_icon_selector(selector)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_icon(icon_name)
    else
      assert page_has_icon?(icon_name)
    end
  end
end

Then /^(?:|I )should not see "([^\"]*)" icon on the "?([^\"]*)"?$/ do |icon_name, selector|
  selector = get_icon_selector(selector)
  if page.has_no_css?(selector)
    page.has_no_css?(selector)
  else
    with_scope(selector) do
      if page.respond_to? :should
        page.should have_no_icon(icon_name)
      else
        assert page_has_no_icon?(icon_name)
      end
    end
  end
end

When /^(?:|I )press "([^\"]*)" icon on the "?([^\"]*)"?$/ do |icon_name, selector|
  selector = get_icon_selector(selector)
  with_scope(selector) do
    click_button(get_icon_button(icon_name, selector), :match => :prefer_exact)
  end
end

When /^(?:|I )follow "([^\"]*)" icon on the "?([^\"]*)"?$/ do |icon_name, selector|
  selector = get_icon_selector(selector)
  with_scope(selector) do
    find(icon_css[icon_name]).click
  end
end