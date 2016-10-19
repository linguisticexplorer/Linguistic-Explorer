Before do
  use_downloading_browser
end

def expect_download_occurred(filename)
  File.exists?(File.join(download_dir, filename)).should be_truthy
end

def use_downloading_browser
  profile = ::Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.folderList'] = 2
  profile['browser.download.dir'] = download_dir
  profile['browser.helperApps.neverAsk.saveToDisk'] = "application/csv,text/csv,application/octet-stream,text/plain"
  Capybara.register_driver :selenium_download do |app|
    Capybara::Selenium::Driver.new(app, {:browser => :firefox, :profile => profile})
  end
  Capybara.current_driver = :selenium_download
end

def download_dir
  @download_dir ||= "#{Dir.pwd}/tmp/downloads"
end

def clear_directory directory
  FileUtils.rm_rf("#{directory}/.", secure: true)
end