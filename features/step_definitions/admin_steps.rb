Given /^Admin permission required$/ do
  text = "Contact the admin"
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
  click_button("close_modal", :match => :prefer_exact)
end

Given /^Admin permission does not required$/ do
  if is_alert_popup_present?
    dismiss_alert_popup
  end
  text = "Contact the admin"
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end