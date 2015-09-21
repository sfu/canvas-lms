require 'yaml'

namespace :sfu do
  desc 'Reset the default Account name and lti_guid. These values need to be reset after a clone from production.'
  task :account_settings, [:stage] => :environment do |t, args|
    stage = args[:stage]
    raise "You must specify a Canvas Capistrano stage (e.g. testing, staging, etc). `rake sfu:account_settings[stage_name]`" if stage.nil?
    sfu = YAML.load_file './config/sfu.yml'
    raise "sfu.yml does not contain a `account_settings` block." if sfu['account_settings'].nil?
    raise "You specified `#{stage}` as the stage, but no such stage is defined in sfu.yml." unless sfu['account_settings'].include? stage

    account_settings = sfu['account_settings'][stage]
    a = Account.default
    puts "Current Account settings:"
    puts "  name: #{a.name}"
    puts "  lti_guid: #{a.lti_guid}"

    puts "Resetting account settings:"
    puts "  name: #{account_settings['name']}"
    puts "  lti_guid: #{account_settings['lti_guid']}"

    Account.transaction do
      a.name = account_settings['name']
      a.lti_guid = account_settings['lti_guid']
      a.save!
    end
  end
end
