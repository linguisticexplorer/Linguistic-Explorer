source 'http://rubygems.org'
#source 'http://gems.github.com'

gem 'rails', '3.0.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '~> 0.2.7'

# Use unicorn as the web server
# gem 'unicorn'
# Use passenger as the web server
gem 'passenger'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'
gem "meta_where", '1.0.1'

# for Users and authentication
gem 'devise', '1.1.7'

gem 'json', '1.5.1'

gem 'validation_reflection', "1.0.0"
gem 'validates_existence', "0.5.6", :git => 'git://github.com/bosh/validates_existence.git'

gem 'cancan', "1.6.4"

gem 'nokogiri', ">= 1.4.4.1", "<=1.5.0.beta.2"
gem 'newrelic_rpm'

# for easy pagination
gem 'will_paginate', '~> 3.0'

# Optimizator query
gem 'slim_scrooge'

# Nice CLI progress bar for ruby
gem "progressbar"

# Will remove prototype in favor of jQuery
gem 'jquery-rails', '>= 0.2.6'

# It forces to use a specific version of Rake
gem 'rake', '0.9.2.2'

# Pure Ruby library to use R language from Ruby code
# it needs that R interpreter is installed and R_HOME is configured
# see https://sites.google.com/a/ddahl.org/rinruby-users/Home for
# more documentation
gem 'rinruby'

# Geomapping gem
gem 'gmaps4rails'

# Forum gem
gem 'forum_monster', :git => 'git://github.com/dej611/forum_monster.git'
gem 'bb-ruby'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test, :pg_test do
  gem 'ruby-debug19'

  # Use mongrel as the web server
  gem 'mongrel', "1.2.0.pre2"

  gem 'rspec', "2.5.0"
  gem 'rspec-rails', "2.5.0"
  gem 'rspec_rails3_validation_expectations', '0.0.2', :git => 'git://github.com/bosh/rspec_rails3_validation_expectations.git'

  gem 'cover_me', '>= 1.2.0'

  gem 'ruby-debug19'
  gem 'factory_girl_rails', "1.1"
  gem "cucumber", "1.0.0"
  gem "database_cleaner", "0.6.7"
  gem "cucumber-rails", "0.4.0" # '0.4.0.beta.1'
  gem 'capybara', "~>0.4.1"
  gem 'launchy'
end

group :pg_test do
  #gem 'pg'
end
