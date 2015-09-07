source 'https://rubygems.org'

# Scaffolding
gem 'rails', '~> 3.2.17'
# # Use passenger as the web server
gem 'passenger'
# # It forces to use a specific version of Rake
gem "rake", "= 10.1.0"
gem "nokogiri", ">= 1.5.6"
# # Nice CLI progress bar for ruby
gem "progressbar"

# # Database
gem 'mysql2'
# # Having problem with new migrations?
# # * Disable slim_scrooge here
# # * Deploy on server with "cap deploy:migrations"
# # * Restore slim_scrooge here
# # * Deploy again on server with "cap deploy"
# # Removed slim_scrooge by now
# # Optimizator query
# #gem 'slim_scrooge'

# # for Users and authentication
gem 'devise'
gem 'humanizer'
gem 'cancancan'
gem 'rolify'

# # Model validation
gem 'validation_reflection', "~> 1.0.0", :git => 'git://github.com/electronicbites/validation_reflection.git'
gem "validates_existence", "~> 0.8.0"

# # Presentation Related gems
gem 'json'
# # Use HAML instead of ERB
gem 'haml-rails'
# # new styles
gem 'will_paginate-bootstrap'
# # for easy pagination
gem 'will_paginate'
# # experimental
gem "alphabetical_paginate", :git => "git://github.com/dej611/alphabetical_paginate.git"
# # iconv for utf-8 to latin1 conversion
gem 'iconv'
# # Bootstrap gem
gem "autoprefixer-rails"
gem 'bootstrap-sass', "~> 3.2.0"
# # Some more icons
gem 'font-awesome-sass', "~> 4.2.0"
# # sass support: it should be out of the assets group!
gem 'sass-rails', '>= 3.2'
# # Use Twitter Typeahead
gem 'twitter-typeahead-rails'

# # Js libs
# # jQuery
gem 'jquery-rails'
# # jQuery UI
gem 'jquery-ui-rails'
# # Add Modernizr to dynamically run HTML5 checks and load JS polyfills conditionally
gem 'modernizr-rails'
# d3js gem -> takes care about updating the JS file
gem 'd3-rails'
# leaflet gem
gem 'leaflet-rails'
# async.js gem
gem 'async-rails'
# replacement for native alert and confirm dialogs
gem 'bootbox-rails', '~>0.4'
# Advances Editor for Property descriptions
gem 'tinymce-rails', '4.0.19'

# Use it to precompile assets
group :assets do
  # No need for coffeescript here, JS it's enough
  gem "uglifier"
end

gem "hogan_assets"

# Forum gem
# gem 'forum_monster', :git => 'https://github.com/dej611/forum_monster.git'
# gem 'bb-ruby'

# # Deploy with Capistrano
gem 'capistrano', "2.15.4"
# gem 'capistrano-multiyaml'
gem "capistrano-ext"
# gem 'net-ssh', "2.7.0"

# # Comment this line if you are not using RVM
# # Starting with RVM 1.11.3 Capistrano integration was extracted to a separate gem.
# # See https://rvm.io/integration/capistrano/
gem 'rvm-capistrano'

# # Debugger and webapp profiling
gem "newrelic_rpm"

# Pure Ruby library to use R language from Ruby code
# it needs that R interpreter is installed and R_HOME is configured
# see https://sites.google.com/a/ddahl.org/rinruby-users/Home for
# more documentation
# Grouped because of Travis-CI
# group :production, :development do
#   gem 'rinruby'
# end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test, :development do

  # Use Thin as web server
  gem "thin"

  # Disable for the moment
  # gem "spork-rails"

  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'shoulda-matchers'
  # gem 'rspec_rails3_validation_expectations', '0.0.2', :git => 'https://github.com/bosh/rspec_rails3_validation_expectations.git'

  gem "cucumber", "~> 1.1.0"

  # Due to the new name resolution approach of the bundler gem it has the require option
  gem 'cucumber-rails', :require => false
  gem 'capybara'
  gem 'launchy'
  gem "database_cleaner", "~> 0.7.0"
  gem 'factory_girl_rails', "~> 1.1"

  # # Query Tracer: useful to debug
  # # Do not activate unless you really need it!
  # # When active it fills all your memory!
  # gem "active_record_query_trace"

  # # Used to test with a real browser
  gem "Selenium"
  gem "selenium-client"
  # # In this case the browser is phantomjs
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'

  # # Metrics, metrics, metrics...
  gem 'brakeman'
  gem 'ruby-prof'
  gem 'metric_fu'
  gem 'rails_best_practices'
  gem 'simplecov', '~> 0.7.1', :require => false

end
