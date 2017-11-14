lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fat_zebra/version'

Gem::Specification.new do |s|
  s.name        = 'fat_zebra'
  s.version     = FatZebra::VERSION
  s.authors     = ['Matthew Savage']
  s.email       = ['matt@amasses.net']
  s.homepage    = ''
  s.summary     = 'Fat Zebra payments gem - integrate your ruby app with Fat Zebra'
  s.description = 'Provides integration with the Fat Zebra internet payment gateway (www.fatzebra.com.au), including purchase, refund, auth, capture and recurring billing functionality.'

  s.rubyforge_project = 'fat_zebra'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = %w[lib]

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.49'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 3.0'
end
