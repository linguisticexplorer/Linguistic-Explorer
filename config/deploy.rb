$: << File.join(File.dirname(__FILE__), "..", "lib")
require "capistrano_database_yml"

# require profile scripts
default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

set :application  , "terraling"
set :deploy_to    , "/var/www/apps/#{application}"
set :deploy_via   , :remote_cache
set :user         , "admin"
set :use_sudo, true

# source control
set :scm          , :git
set :repository   , "git://github.com/linguisticexplorer/Linguistic-Explorer.git"
set :branch       , "master"


# role :web, HTTP server (Apache)/etc
# role :app, app server
# role :db, master db server
server "50.56.97.125:10003", :app, :web, :db, :primary => true

# RVM Ruby Version Manager
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
require "rvm/capistrano"
set :rvm_ruby_string, "1.9.2-head@ling"                 # set rvm ruby version and gemset
set :rvm_type, :user

# Bundler
require 'bundler/capistrano'

# Passenger mod_rails:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
