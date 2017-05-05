$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sfu_help/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sfu_help"
  s.version     = SFU::Help::VERSION
  s.authors     = ["Graham Ballantyne"]
  s.email       = ["grahamb@sfu.ca"]
  s.homepage    = ""
  s.summary     = "Overrides Canvas::Help.default_links to return an empty array."

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.test_files = Dir["spec_canvas/**/*"]

  s.add_dependency "rails", ">= 3.2", "< 5.1"
end
