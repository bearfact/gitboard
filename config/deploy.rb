# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'gitboard'
set :deploy_user, 'deployer'


set :assets_roles, [:app]

# setup repo details
set :scm, :git
set :repo_url, 'git@github.com:bearfact/gitboard.git'

# how many old releases do we want to keep
set :keep_releases, 5

# set :workers, { "users_queue" => 1 }

# Uncomment this line if your workers need access to the Rails environment:
# set :resque_environment_task, true

# set :resque_log_file, "log/resque.log"

# files we want symlinking to specific entries in shared.
set :linked_files, %w{config/database.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
set :tests, []

# which config files should be copied by deploy:setup_config
# see documentation in lib/capistrano/tasks/setup_config.cap
# for details of operations
set(:config_files, [
  "nginx-#{fetch(:stage)}.conf",
  "log_rotation",
  "monit",
  "thin-#{fetch(:stage)}.yml",
  "thin_init.sh"
])

# which config files should be made executable after copying
# by deploy:setup_config
set(:executable_config_files, %w(
  thin_init.sh
))

# files which need to be symlinked to other parts of the
# filesystem. For example nginx virtualhosts, log rotation
# init scripts etc.
set(:symlinks, [
  {
    source: "nginx-#{fetch(:stage)}.conf",
    link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
  },
  {
    source: "thin_init.sh",
    link: "/etc/init.d/thin_#{fetch(:full_app_name)}"
  },
  {
    source: "log_rotation",
   link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
  },
  {
    source: "monit",
    link: "/etc/monit/conf.d/#{fetch(:full_app_name)}.conf"
  },
  {
    source: "thin-#{fetch(:stage)}.yml",
    link: "/etc/thin/#{fetch(:full_app_name)}.yml"
  }
])

namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/deploy/shared/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "Symlinks config files for Nginx and Thin."
  task :symlink_config do
    on roles(:app) do
      execute "sudo rm -f /etc/nginx/sites-enabled/default"
      execute "sudo ln -nfs #{current_path}/config/deploy/shared/nginx-#{fetch(:stage)}.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/deploy/shared/thin_init.sh /etc/init.d/thin_#{fetch(:application)}"
      execute "chmod +x /etc/init.d/thin_#{fetch(:application)}"
      execute "mkdir -p /etc/thin && ln -nfs #{current_path}/config/deploy/shared/thin-#{fetch(:stage)}.yml /etc/thin/#{fetch(:application)}.yml"
      execute "ln -nfs #{current_path}/config/deploy/shared/log_rotation /etc/logrotate.d/#{fetch(:application)}"
      execute "mkdir -p /etc/monit && ln -nfs #{current_path}/config/deploy/shared/monit /etc/monit/conf.d/#{fetch(:application)}"
   end
  end

  desc "Restart nginx"
  task :nginx_restart do
    on roles(:app) do
      execute "service nginx restart"
    end
  end

end

# this:
# http://www.capistranorb.com/documentation/getting-started/flow/
# is worth reading for a quick overview of what tasks are called
# and when for `cap stage deploy`

namespace :deploy do

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
      puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} thin server."
    task command do
      on roles(:app) do
        execute "service thin #{command} -C /etc/thin/gitboard.yml"
      end
    end
  end

  desc "bower install all the things"
  task :bower_install do
      on roles(:app) do
          execute "cd #{release_path} && bower install"
      end
  end
  after :updating, "deploy:bower_install"



  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"
  # only allow a deploy with passing tests to deployed
  #before :deploy, "deploy:run_tests"
  # compile assets locally then rsync
  #after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'

  # remove the default nginx configuration as it will tend
  # to conflict with our configs.
  #before 'deploy:setup_config', 'nginx:remove_default_vhost'

  # reload nginx to it will pick up any modified vhosts from
  # setup_config
  #after 'deploy:setup_config', 'nginx:reload'

  # Restart monit so it will pick up any monit configurations
  # we've added
  #after 'deploy:setup_config', 'monit:restart'

  # As of Capistrano 3.1, the `deploy:restart` task is not called
  # automatically.
  before 'deploy:cleanup', 'setup:symlink_config'

  after 'deploy:cleanup', 'deploy:stop'
  after 'deploy:stop', 'deploy:start'
  after 'deploy:start', 'setup:nginx_restart'

  #restart resque works
  #after "deploy:publishing", "deploy:restart_workers"

end

