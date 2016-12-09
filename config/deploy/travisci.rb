# SSH Settings
set :user     , "deploy"
set :use_sudo , true

ssh_options_hash = { :forward_agent => true }
ssh_options_hash[:keys] = ["tmp/deploy_rsa"] if File.exist?("tmp/deploy_rsa")
set :ssh_options, ssh_options_hash

server "ec2-54-68-27-245.us-west-2.compute.amazonaws.com", :app, :web, :db, :primary => true

# Application settings
set :rails_env, :production
set :branch,    "sprint"

# RVM settings
set :rvm_ruby_string, "2.1.2"

set :deploy_to    , "/home/deploy/apps/#{application}"
