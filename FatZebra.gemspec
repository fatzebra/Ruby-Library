# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fat_zebra/version"

Gem::Specification.new do |s|
  s.name        = "fat_zebra"
  s.version     = FatZebra::VERSION
  s.authors     = ["Matthew Savage"]
  s.email       = ["matt@amasses.net"]
  s.homepage    = ""
  s.summary     = %q{Fat Zebra payments gem - integrate your ruby app with Fat Zebra}
  s.description = %q{Provides integration with the Fat Zebra internet payment gateway (www.fatzebra.com.au), including purchase, refund, auth, capture and recurring billing functionality.}

  s.rubyforge_project = "fat_zebra"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
  s.add_development_dependency "yard-tomdoc"
  

  s.add_runtime_dependency "rest-client", "2.0.0.rc2"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "activesupport", ">= 3.2"
end
