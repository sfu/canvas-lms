$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sfu_copyright/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sfu_copyright"
  s.version     = SFU::Copyright::VERSION
  s.authors     = ["Andrew Leung"]
  s.email       = ["andrewleung@sfu.ca"]
  s.description = "Contains materials related to Copyright Compliance"
  s.summary = "Contains materials related to Copyright Compliance"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]

  s.add_dependency "rails", ">= 3.2", "< 5.1"
end
