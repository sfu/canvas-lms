namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:all) do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end

namespace :canvas do

  desc "Fix ownership on canvas install directory"
  task :fix_owner do
    on roles(:all) do
      user = fetch :user
      execute :chown, '-R', "#{user}:#{user}", "#{release_path}"
    end
  end

  desc "Set application nodes from config file"
  task :set_app_nodes do
    on primary :db do
      stage = fetch :stage
      prefix = fetch :app_node_prefix
      nodes = capture "/usr/local/canvas/bin/getappnodes #{stage}"
      range = *(1..nodes.to_i)
      # roles[:app].clear
      range.each do |node|
        server "#{prefix}#{node}.tier2.sfu.ca", roles: [:app]
        # parent.role :app, "#{prefix}#{node}.tier2.sfu.ca"
      end
    end
  end

  desc "Run the copy_config script"
  task :copy_config do
    on roles(:all) do
      execute "sudo CANVASDIR=#{release_path} /etc/init.d/canvasconfig start"
    end
  end

  desc "Log the deploy to graphite"
  task :log_deploy do
    ts = Time.now.to_i
    stage = fetch :stage
    stats_server = fetch :stats_server
    cmd = "echo 'stats.canvas.#{stage}.deploys 1 #{ts}' | nc #{stats_server} 2003"
    run_locally do
      execute cmd
    end
  end

  desc "Ping the canvas server to actually restart the app"
  task :ping do
    run_locally do
      execute "curl -m 10 --silent #{fetch(:canvas_url)}/sfu/api/v1/terms/current"
    end
  end

  desc "Create symlink for files folder to mount point"
  task :symlink_canvasfiles do
    on roles(:all) do
      execute "mkdir -p #{release_path}/mnt/data && ln -s /mnt/data/canvasfiles #{release_path}/mnt/data/canvasfiles"
    end
  end

  desc "Reset account settings for non-production environments"
  task :reset_account_settings do
    next unless fetch(:reset_account_settings)
    on primary :db do
      within release_path do
        with rails_env: fetch(:rails_env) do
          stage = fetch :stage
          execute :rake, "sfu:account_settings[#{stage}]"
        end
      end
    end
  end

  desc "Rebuild brand_configs"
  task :build_brand_configs do
    on primary :db do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "brand_configs:generate_and_upload_all"
        end
      end
    end
  end

  desc "Move brandable_css"
  task :move_brandable_css do
    on primary :db do
      execute "mkdir -p #{fetch(:shared_brandable_css_base)} && cp -r #{release_path}/public/dist/brandable_css #{fetch(:shared_brandable_css_path)}"
    end
  end

  desc "Symlink brandable_css"
  task :symlink_brandable_css do
    on roles(:all) do
      local_path = fetch(:local_brandable_css_path)
      execute "rm -rf #{local_path} && ln -s #{fetch(:shared_brandable_css_path)} #{local_path}"
    end
  end

  desc "Clean up brandable_css"
  task :cleanup_brandable_css do
    on primary :db do
      shared_path = fetch(:shared_brandable_css_base)
      releases = capture(:ls, "-xtr", shared_path).split
      if releases.count >= fetch(:keep_releases)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            "#{shared_path}/#{release}"
          end.join(" ")
          execute :rm, "-rf", directories_str
        end
      end
    end
  end


end
