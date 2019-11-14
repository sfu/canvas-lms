Rails.configuration.to_prepare do
  require_dependency 'aaa_sfu_misc/test_cluster'
  require_dependency 'aaa_sfu_misc/request_throttle_whitelist'
end

# This is so Rails will log the actual IP address in the log (X-Forwarded-For header added by the NSX load balancer)
# https://github.com/rails/rails/issues/5223#issuecomment-263778719
module TrustedProxyMonkeyPatch
  def ip
    @ip ||= (get_header("action_dispatch.remote_ip") || super).to_s
  end
end
ActionDispatch::Request.send :include, TrustedProxyMonkeyPatch