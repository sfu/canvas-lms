num_app_nodes = 6
app_node_prefix = "canvas-ap"

push_app_servers(num_app_nodes, app_node_prefix)
role :db, "canvas-mp.tier2.sfu.ca", :primary => true

set :rails_env, "production"