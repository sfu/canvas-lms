$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sfu_stats/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sfu_stats"
  s.version     = SFUStats::VERSION
  s.authors     = ["Graham Ballantyne"]
  s.email       = ["grahamb@sfu.ca"]
  s.description = "SFU Stats plugin for canvas-lms"
  s.summary = "SFU Stats plugin for canvas-lms"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2", "< 5.1"
end
