#need it when an alert popup shows up on the screen
def accept_alert_popup
  page.driver.browser.switch_to.alert.accept
end

def is_alert_popup_present?
  begin
    page.driver.browser.switch_to.alert.present?
  rescue Selenium::WebDriver::Error::NoSuchAlertError
    false
  end
end

def dismiss_alert_popup
  page.driver.browser.switch_to.alert.dismiss
end

def choose_field(selector, field)
  with_scope(selector) do
    choose(field, match: :prefer_exact)
  end
end