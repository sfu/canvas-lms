$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sfu_api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sfu_api'
  s.version     = SFU::API::VERSION
  s.authors     = ['Ron Santos', 'Andrew Leung', 'grahamb@sfu.ca']
  s.email       = ['santos@sfu.ca', 'andrewleung@sfu.ca', 'grahamb@sfu.ca']
  s.description = 'SFU-specific API routes'
  s.summary     = 'SFU-specific API routes'
  s.files       = Dir['{app,config,db,lib}/**/*'] + ['README']

  s.add_dependency "rails", ">= 3.2", "< 5.1"
  s.add_dependency 'rest-client'
  s.add_dependency 'httpclient'
end
