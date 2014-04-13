source 'https://rubygems.org'

gem 'rails', '3.0.20'

# Bundle edge Rails instead:
# gem 'rails', :git => 'https://github.com/rails/rails.git'

gem 'mysql2', '~> 0.2.7'

# Use unicorn as the web server
# gem 'unicorn'
# Use passenger as the web server
gem 'passenger'

# Deploy with Capistrano
gem 'capistrano'

# Comment this line if you are not using RVM
# Starting with RVM 1.11.3 Capistrano integration was extracted to a separate gem.
# See https://rvm.io/integration/capistrano/
gem 'rvm-capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'
gem "meta_where", '1.0.1'

# for Users and authentication
gem 'devise', '1.1.7'
gem 'humanizer'

gem 'json', '1.7.7'

gem 'validation_reflection', "1.0.0"
gem 'validates_existence', "0.5.6", :git => 'https://github.com/bosh/validates_existence.git'

gem 'cancan', "1.6.4"

gem 'nokogiri', ">= 1.4.4.1", "<=1.5.0.beta.2"
gem 'newrelic_rpm'

# for easy pagination
gem 'will_paginate', '~> 3.0'

# new styles
gem 'will_paginate-bootstrap'


# Having problem with new migrations?
# * Disable slim_scrooge here
# * Deploy on server with "cap deploy:migrations"
# * Restore slim_scrooge here
# * Deploy again on server with "cap deploy"
# Removed slim_scrooge by now
# Optimizator query
#gem 'slim_scrooge'

# Nice CLI progress bar for ruby
gem "progressbar"

# Will remove prototype in favor of jQuery
gem 'jquery-rails', '>= 0.2.6'

# It forces to use a specific version of Rake
gem 'rake', '0.9.2.2'

# Geomapping gem
gem 'gmaps4rails', "=1.5.6"

# Forum gem
gem 'forum_monster', :git => 'https://github.com/dej611/forum_monster.git'
gem 'bb-ruby'

group :development do
  gem 'ruby-debug19'
end

#sass support
gem 'sass'

#experimental
gem "alphabetical_paginate"

#iconv for utf-8 to latin1 conversion
gem 'iconv'

# Pure Ruby library to use R language from Ruby code
# it needs that R interpreter is installed and R_HOME is configured
# see https://sites.google.com/a/ddahl.org/rinruby-users/Home for
# more documentation
# Grouped because of Travis-CI
group :production, :development do
  gem 'rinruby'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test, :development do
  # Use mongrel as the web server
  gem 'mongrel', "1.2.0.pre2"

  gem 'rspec', "2.5.0"
  gem 'rspec-rails', "2.5.0"
  gem 'rspec_rails3_validation_expectations', '0.0.2', :git => 'https://github.com/bosh/rspec_rails3_validation_expectations.git'

  gem 'factory_girl_rails', "1.1"
  gem "cucumber", "1.0.0"
  gem "Selenium"
  gem "selenium-client"
  gem "database_cleaner", "0.6.7"
  # Due to the new name resolution approach of the bundler gem it has the require option
  gem "cucumber-rails", "0.4.0", :require => false # '0.4.0.beta.1'
  gem 'capybara', "~>0.4.1"
  gem 'launchy'
  gem 'brakeman'
end
