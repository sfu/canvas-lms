require 'capistrano-scm-copy'
set :scm, :copy
set :copy_local_tar, "/usr/local/bin/gtar" if `uname` =~ /Darwin/

set :stage, :snapshot
role :app, "canvas-snapshot.tier2.sfu.ca"
role :db, "canvas-snapshot.tier2.sfu.ca", :primary => true
set :canvas_url, 'https://canvas-snapshot.its.sfu.ca'

set :rails_env, "production"
set :branch, ENV['branch'] || 'sfu-deploy'

set :default_env, {
  'PATH' => '/usr/pgsql-9.1/bin:$PATH'
}

set :shared_brandable_css_base, "#{shared_path}/public/brandable_css/"
set :shared_brandable_css_path, "#{fetch(:shared_brandable_css_base)}#{release_timestamp}"
