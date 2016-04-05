require 'capistrano-scm-copy'
set :scm, :copy
set :copy_local_tar, "/usr/local/bin/gtar" if `uname` =~ /Darwin/

set :stage, :production
set :app_node_prefix, "canvas-ap"
set :canvas_url, 'https://canvas.sfu.ca'
set :reset_account_settings, false

role :db,  %w{canvas-mp1.tier2.sfu.ca canvas-mp2.tier2.sfu.ca}

namespace :deploy do
  before :started, 'canvas:set_app_nodes'
end

set :default_env, {
  'PATH' => '/usr/pgsql-9.1/bin:$PATH'
}

set :shared_brandable_css_base, "/mnt/data/brandable_css/"
set :shared_brandable_css_path, "#{fetch(:shared_brandable_css_base)}#{release_timestamp}"
