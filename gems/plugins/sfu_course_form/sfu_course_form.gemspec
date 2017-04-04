$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sfu/course_form/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sfu_course_form'
  s.version     = SFU::CourseForm::VERSION
  s.authors     = ['Andrew Leung']
  s.email       = ['andrewleung@sfu.ca']
  s.description = 'Custom Start a New Course form for creating SFU credit, non-credit and sandbox courses.'
  s.summary     = 'Custom Start a New Course form'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['README.md']

  s.add_dependency "rails", ">= 3.2", "< 5.1"
end
