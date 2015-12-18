ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'rails/test_help'
require 'spec_helper'

# copied from sfu_api factories; should centralize this somewhere
def enrollment_term_model(opts={})
  do_save = opts.has_key?(:save) ? opts.delete(:save) : true
  @enrollment_term = factory_with_protected_attributes(EnrollmentTerm, valid_enrollment_term_attributes.merge(opts), do_save)
end

def valid_enrollment_term_attributes
  {
    :name => 'value for name',
    :sis_source_id => 'value for sis id',
    :root_account_id => Account.default.id,
    :start_at => DateTime.now,
    :end_at => DateTime.now + 60.days,
    :workflow_state => 'active'
  }
end

RSpec.configure do |config|
  config.before(:suite) do
    enrollment_term_model(
      :name => 'Current Term',
      :sis_source_id => '1141',
      :start_at => DateTime.now,
      :end_at => DateTime.now + 60.days,
      :workflow_state => 'active'
      )
  end

  config.expect_with :rspec do |c|
    # The `should` syntax is deprecated in RSpec 3; keep it alive until we get a chance to switch to `expect`.
    c.syntax = [:should, :expect]
  end
end
