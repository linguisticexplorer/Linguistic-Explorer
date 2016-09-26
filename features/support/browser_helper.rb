#need it when an alert popup shows up on the screen
def accept_alert_popup
  page.driver.browser.switch_to.alert.accept
end