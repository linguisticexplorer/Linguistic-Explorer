# Load the rails application
require File.expand_path('../application', __FILE__)

unless defined? DEFAULT_PER_PAGE
  # see: http://groups.google.com/group/will_paginate/browse_thread/thread/eda47114e3127709
  ActiveRecord::Base.instance_eval do
    def per_page; 25; end
  end
  DEFAULT_PER_PAGE = ActiveRecord::Base.per_page
end

# Initialize the rails application
LinguisticExplorer::Application.initialize!
