require 'knapsack'

Knapsack.tracker.config({
  enable_time_offset_warning: true,
  time_offset_in_seconds: 30
})

Knapsack.report.config({
  test_file_pattern: 'spec/**{,/*/**}/*_spec.rb', # default value based on adapter
  report_path: 'knapsack_cucumber_report.json'
})

# you can use your own logger
require 'logger'
Knapsack.logger = Logger.new(STDOUT)
Knapsack.logger.level = Logger::INFO

Knapsack::Adapters::CucumberAdapter.bind
