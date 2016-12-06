set :stages       , %w(testing production travisci)
set :default_stage, "production"

require "capistrano/ext/multistage"
require "bundler/capistrano"

# require profile scripts
default_run_options[:pty]   = true
# ssh_options[:forward_agent] = true

# if :aws_deploy
#   # ssh_options[:auth_methods]  = [:public_key]
#   ssh_options[:keys]          = ["/home/dej611/.ssh/aws-free.pem"]
# end


set :application  , "terraling"
# set :deploy_to    , "/var/www/apps/#{application}"
set :deploy_via   , :remote_cache
# set :user         , "admin"
# set :use_sudo     , true
# set :multiyaml_stages, "yamls/deploy.yml"
set :keep_releases, 3

# source control
set :scm          , :git
set :scm_verbose  , true
set :repository   , "git://github.com/linguisticexplorer/Linguistic-Explorer.git"
# set :branch       , "master"
set :copy_exclude , ['.git']

# require "capistrano-multiyaml"


# role :web, HTTP server (Apache)/etc
# role :app, app server
# role :db, master db server
# server "50.56.97.125:10003", :app, :web, :db, :primary => true

require "rvm/capistrano"
$: << File.join(File.dirname(__FILE__), "..", "lib")

begin
  # RVM Ruby Version Manager
  $:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
  require "rvm/capistrano"
  # set :rvm_ruby_string, "1.9.2-head@ling"                 # set rvm ruby version and gemset
  set :rvm_type, :user
rescue LoadError
  puts "rvm not installed"
end

# Bundler
require 'bundler/capistrano'

# Passenger mod_rails:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # Update the gems
    # run "/usr/bin/env bundle install"
    # Update the DB in case (it should not be necessary, but just in case...)
    # Note: Remember to backup before deploying...
    # run "/usr/bin/env bundle exec rake db:migrate"
    # Restart
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# Import and download tasks
require 'group_data/capistrano'

# Setup production database.yml
require "capistrano_database_yml"