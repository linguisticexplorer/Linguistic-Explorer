#need it when an alert popup shows up on the screen
def accept_alert_popup
  page.driver.browser.switch_to.alert.accept
end

def choose_field(field, options)
  scroll_to(field)
  choose(field, :match => :prefer_exact)
end

def scroll_to(element)
  script = <<-JS
    arguments[0].scrollIntoView(true);
  JS

  Capybara.current_session.driver.browser.execute_script(script, element.native)
end