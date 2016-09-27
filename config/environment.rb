# Load the rails application
require File.expand_path('../application', __FILE__)

unless defined? ActiveRecord::Base.per_page
  # see: http://groups.google.com/group/will_paginate/browse_thread/thread/eda47114e3127709
  ActiveRecord::Base.instance_eval do
    def per_page; 25; end
  end
end

# Initialize the rails application
LinguisticExplorer::Application.initialize!
