When /^I debug the test$/ do
  require "ruby-debug"; debugger
  true
end

Then /^show me the page$/ do
  save_and_open_page
end
