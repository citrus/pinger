# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pinger/version"

Gem::Specification.new do |s|
  s.name        = "pinger"
  s.version     = Pinger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spencer Steffen"]
  s.email       = ["spencer@citrusme.com"]
  s.homepage    = ""
  s.summary     = %q{Pinger checks on our sites.}
  s.description = %q{Pinger makes sure our websites are responding properly and in a timely fashion.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("eventmachine", ">= 0.12.10")
  
  s.add_development_dependency("shoulda", ">= 2.11.3")
  
end
