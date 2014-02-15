# This file is copied to spec/ when you run 'rails generate rspec:install'

require "spork"

Spork.prefork do
  # Simplecov needs to start at the top
  require 'simplecov'

  ENV["RAILS_ENV"] ||= 'test'

  # Requires all dependencies here
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'database_cleaner'
  # Removed
  # require 'validates_existence/rspec_macros'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  %w[ support helpers ].each do |dir|
    Dir[Rails.root.join("spec/#{dir}/**/*.rb")].each {|f| require f}
  end

  RSpec.configure do |config|
    include CSVHelper

    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # include validates_existence helpers
    # config.include(ValidatesExistence::RspecMacros)

    # include spec helpers in controllers
    config.include Devise::TestHelpers, :type => :controller

    # use all fixtures
    config.global_fixtures = :all

    config.before(:suite) do
      FactoryGirl.reload
      # cleans the log file, make it readable and control its size
      File.open("#{Rails.root}/log/test.log", "w") {|file| file.truncate(0) }
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      DatabaseCleaner.clean
    end
  end
  
  # Hack to profile dependencies importing time:
  # enable it in case rspec becomes veeery slow and preload some dep
  
  # module Kernel
  #   def require_with_trace(*args)
  #     start = Time.now.to_f
  #     @indent ||= 0
  #     @indent += 2
  #     require_without_trace(*args)
  #     @indent -= 2
  #     Kernel::puts "#{' '*@indent}#{((Time.now.to_f - start) * 1000).to_i} #{args[0]}"
  #   end
  #   alias_method_chain :require, :trace
  # end
end

Spork.each_run do
end
