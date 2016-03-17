require 'capistrano-scm-copy'
set :scm, :copy
set :copy_local_tar, "/usr/local/bin/gtar" if `uname` =~ /Darwin/

set :stage, :cuttingedge
role :app, "canvas-edge.tier2.sfu.ca"
role :db, "canvas-edge.tier2.sfu.ca", :primary => true
set :canvas_url, 'https://canvas-edge.sfu.ca'

set :rails_env, "production"
set :branch, ENV['branch'] || 'edge'

set :default_env, {
  'PATH' => '/usr/pgsql-9.1/bin:$PATH'
}

namespace :canvas do
  desc "Create symlink for files folder to mount point"
  task :symlink_canvasfiles do
    on roles(:all) do
      execute "ln -s #{shared_path}/tmp/files #{release_path}/tmp/files"
    end
  end
end
