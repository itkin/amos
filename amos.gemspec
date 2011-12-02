# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amos/version"

Gem::Specification.new do |s|
  s.name = "amos"
  s.version = Amos::VERSION

  s.summary = "amos - a model only server."
  s.description = "A simple server that determines the model and action data based upon the incoming url."

  s.author = 'Geoff Drake'
  s.email = 'drakeg@mandes.com'
  s.homepage = 'http://rubygems.org/gems/amos'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.8.1'
  s.add_dependency('rails', '>= 3.0.0')
  s.add_dependency('cancan', '>= 1.6.6')
  
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('sqlite3-ruby')
  s.add_development_dependency('ruby-debug')
  s.add_development_dependency('launchy')
  s.add_development_dependency('syntax')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('factory_girl_rails')
  s.add_development_dependency('cucumber-rails')
  s.add_development_dependency('pickle')

end

