Rails.configuration.to_prepare do
  require_dependency 'aaa_sfu_misc/test_cluster'
  require_dependency 'aaa_sfu_misc/request_throttle_whitelist'
end
