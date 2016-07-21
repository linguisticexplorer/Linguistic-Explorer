def add_languange_button
  find(".fa-plus")
end

def descripition_frame
  find_by_id( "desc_ifr")
end

def language_edit_dropdown
  find(".btn.btn-default.dropdown-toggle")
end

def return_to_language_button
  find(".fa.fa-arrow-left")
end

def description_tab_box
  find(".text-justify > p:nth-child(2)")
end

def property_value_table
  find('table.show-table:nth-child(2)')
end

def property_value_table_first_value
  property_value_table.find("tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)")
end

When /^I click on Group named "([^"]*)"$/ do |group_name|
  find('a', text: "Pick a Dataset").hover
  click_link group_name
end

Then /^I click to create a new language$/ do
  click_link "Languages"
  add_languange_button.click
end

Then /^I set the language name to "([^"]*)"$/ do |language_name|
  fill_in "ling_name", :with => language_name
end

Then /^I enter a description for the language to "([^"]*)"$/ do |language_description|
  within_frame(descripition_frame) do
    find('body').set(language_description)
  end
end

Then /^I save the language$/ do
  click_button "Submit"
end

Then /^I set a property value to "([^"]*)"$/ do |prop_val|
  Capybara.ignore_hidden_elements = false
  language_created_alert = find_by_id(:messages).find(".alert.alert-success")
  begin
    # Wait for the success box to go away
  end while language_created_alert.visible?
  Capybara.ignore_hidden_elements = true
  language_edit_dropdown.click
  click_link "Values"
  find(".radio").choose prop_val
  click_button "Certain"
end

Then /^I create an example for the given value with the name "([^"]*)", gloss "([^"]*)", and number "([^"]*)"$/ do |name, gloss, number|
  click_link "Create Example"
  fill_in "Name", with: name
  fill_in "Gloss", with: gloss
  fill_in "Number", with: number
  click_button "Create Example"
end

Then /^I set a new propery value to "([^"]*)"$/ do |arg1|
  execute_script('window.scroll(0,-1000);') # scroll up
  find_by_id("value_value_new").set(true)
  fill_in "new_value", with: "#{arg1}\n"
  click_button "Certain"
end

When /^I go back to the language page$/ do
  visit "#{current_path}#"
  return_to_language_button.click
end

Then /^I should see that the language "([^"]*)" is set by "([^"]*)"$/ do |language_name, author_name|
  expect(page).to have_text("Languages : #{language_name}")
  expect(page).to have_text "Set by #{author_name}"
end

Then /^the language description is set to "([^"]*)"$/ do |language_description|
  click_link "Description"
  expect(description_tab_box).to have_text(language_description)
end

Then /^that it has an example with gloss "([^"]*)" and number "([^"]*)"$/ do |gloss, number|
  expect(page).to have_text("Gloss: #{gloss}")
  expect(page).to have_text("Number: #{number}")
end

Then /^the language has a property value set to "([^"]*)"$/ do |value|
  expect(property_value_table_first_value).to have_text(value)
end
