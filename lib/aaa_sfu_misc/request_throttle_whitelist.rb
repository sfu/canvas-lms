class RequestThrottle
  alias_method :whitelisted_original?, :whitelisted?
  def whitelisted?(request)
    if request.fullpath.to_s.start_with?("/health_check") &&
        request.headers['User-Agent'].to_s.include?("Hobbit")
      true
    else
      whitelisted_original?(request)
    end
  end
end