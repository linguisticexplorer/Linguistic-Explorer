$: << File.join(File.dirname(__FILE__), "..", "lib")
require "capistrano_database_yml"

# require profile scripts
default_run_options[:pty] = true

set :application, "terraling"
set :deploy_to,  "/var/www/apps/#{application}"

# source control
set :scm, :git
set :repository,  "git://github.com/linguisticexplorer/Linguistic-Explorer.git"

# role :web, "50.56.97.125:10003"                          # Your HTTP server, Apache/etc
# role :app, "50.56.97.125:10003"                          # This may be the same as your `Web` server
# role :db,  "50.56.97.125:10003", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"
server "50.56.97.125:10003", :app, :web, :db, :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts
ssh_options[:forward_agent] = true
set :branch, "ruby-1.9.2"
set :deploy_via, :remote_cache
set :user, "admin"

# RVM Ruby Version Manager
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, "1.9.2-head@ling"        # Or whatever env you want it to run in.
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

# # Bundler
# namespace :bundler do
#   task :create_symlink, :roles => :app do
#     shared_dir = File.join(shared_path, 'bundle')
#     release_dir = File.join(release_path, '.bundle')
#     run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
#   end
# 
#   task :install, :roles => :app do
#     run "cd #{release_path} && bundle install --local --without test pg_test development"
# 
#     on_rollback do
#       if previous_release
#         run "cd #{previous_release} && bundle install --local --without test pg_test development"
#       else
#         logger.important "no previous release to rollback to, rollback of bundler:install skipped"
#       end
#     end
#   end
# 
#   task :bundle_new_release, :roles => :db do
#     bundler.create_symlink
#     bundler.install
#   end
# 
#   after "deploy:rollback:revision", "bundler:install"
#   after "deploy:update_code", "bundler:bundle_new_release"
# 
#   #"deploy:symlink_shared", "newrelic:notice_deployment"
# end
