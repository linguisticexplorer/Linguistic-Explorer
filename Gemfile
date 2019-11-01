source 'https://rubygems.org'

# Scaffolding
gem 'rails', '~> 3.2.17'
# # Use passenger as the web server
gem 'passenger', "~>4.0.50"
# # It forces to use a specific version of Rake
gem "rake", "= 10.1.0"
gem "nokogiri", ">= 1.5.6"
# # Nice CLI progress bar for ruby
gem "progressbar", "~>0.21.0"

# # Database
gem 'mysql2', '~>0.3.17'
# # Having problem with new migrations?
# # * Disable slim_scrooge here
# # * Deploy on server with "cap deploy:migrations"
# # * Restore slim_scrooge here
# # * Deploy again on server with "cap deploy"
# # Removed slim_scrooge by now
# # Optimizator query
# #gem 'slim_scrooge'

# # for Users and authentication
gem 'devise',    "~>3.3.0"
gem 'humanizer', "~>2.6.0"
gem 'cancancan', "~>1.10.1"
gem 'rolify',    "~>4.1.1"

# # Model validation
gem 'validation_reflection', "~> 1.0.0", :git => 'git://github.com/electronicbites/validation_reflection.git'
gem "validates_existence", "~> 0.8.0"

# # Presentation Related gems
gem 'json', "~>1.8.1"
# # Use HAML instead of ERB
gem 'haml-rails', "~>0.4"
# # new styles
gem 'will_paginate-bootstrap', "~>1.0.1"
# # for easy pagination
gem 'will_paginate', "~>3.0.7"
# # experimental
gem "alphabetical_paginate", :git => "git://github.com/dej611/alphabetical_paginate.git"
# # iconv for utf-8 to latin1 conversion
gem 'iconv', "~>1.0.4"
# # Bootstrap gem
gem "autoprefixer-rails", "~>3.0.1"
gem 'bootstrap-sass', "~> 3.2.0"
# # Some more icons
gem 'font-awesome-sass', "~> 4.2.0"
# # sass support: it should be out of the assets group!
gem 'sass-rails', '~>3.2'
# # Use Twitter Typeahead
gem 'twitter-typeahead-rails', "~>0.10.5"

# # Js libs
# # jQuery
gem 'jquery-rails', "~>3.1.2"
# # jQuery UI
gem 'jquery-ui-rails', "~>5.0.0"
# # Add Modernizr to dynamically run HTML5 checks and load JS polyfills conditionally
gem 'modernizr-rails', "~>2.7.1"
# d3js gem -> takes care about updating the JS file
gem 'd3-rails', "~>3.4.11"
# leaflet gem
gem 'leaflet-rails', "~>0.7.3"
# async.js gem
gem 'async-rails', "~>0.9.0"
# replacement for native alert and confirm dialogs
gem 'bootbox-rails', '~>0.4'
# Advances Editor for Property descriptions
gem 'tinymce-rails', '~>4.0.19'

# Use it to precompile assets
group :assets do
  # No need for coffeescript here, JS it's enough
  gem "uglifier", "~>2.5.3"
end

group :deploy do
  # # Deploy with Capistrano
  gem 'capistrano', "~>2.15.4"
  # gem 'capistrano-multiyaml'
  gem "capistrano-ext", "~>1.2.1"
  # # Comment this line if you are not using RVM
  # # Starting with RVM 1.11.3 Capistrano integration was extracted to a separate gem.
  # # See https://rvm.io/integration/capistrano/
  gem 'rvm-capistrano', "~>1.5.4"
end

gem "hogan_assets", "~>1.6.0"

# Forum gem
# gem 'forum_monster', :git => 'https://github.com/dej611/forum_monster.git'
# gem 'bb-ruby'

gem 'net-ssh', "~>2.9.1"
gem 'net-scp', "~>1.2.1"


# # Debugger and webapp profiling
gem "newrelic_rpm", "~>3.9.4"

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
  gem "thin", "~>1.6.2"

  # Disable for the moment
  # gem "spork-rails"

  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'shoulda-matchers', "~>2.7.0"
  # gem 'rspec_rails3_validation_expectations', '0.0.2', :git => 'https://github.com/bosh/rspec_rails3_validation_expectations.git'

  gem "cucumber", "~> 1.1.0"

  # Due to the new name resolution approach of the bundler gem it has the require option
  gem 'cucumber-rails', :require => false
  gem 'capybara', "~>2.7.1"
  gem 'launchy', "~>2.4.2"
  gem "database_cleaner", "~> 0.7.0"
  gem 'factory_girl_rails', "~> 1.1"

  # # Query Tracer: useful to debug
  # # Do not activate unless you really need it!
  # # When active it fills all your memory!
  # gem "active_record_query_trace"

  # # Used to test with a real browser
  gem "selenium", "~>0.2.11"
  gem "selenium-webdriver", "~>2.53.4"
  gem "selenium-client", "~>1.2.18"
  # # In this case the browser is phantomjs
  # gem 'poltergeist'
  # gem 'phantomjs', :require => 'phantomjs/poltergeist'

  # # Metrics, metrics, metrics...
  gem 'brakeman', "~>2.6.2"
  gem 'ruby-prof', "~>0.15.1"
  gem 'metric_fu', "~>4.11.1"
  gem 'rails_best_practices', "~>1.15.4"
  gem 'simplecov', '~> 0.7.1', :require => false

end

group :development do
  gem 'pry'
  gem 'pry-byebug', :platform => :ruby_20
  gem 'awesome_print', require:'ap'
  gem 'meta_request'
end

gem 'redcarpet'
