ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'rails/test_help'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # The `should` syntax is deprecated in RSpec 3; keep it alive until we get a chance to switch to `expect`.
    c.syntax = [:should, :expect]
  end
end
