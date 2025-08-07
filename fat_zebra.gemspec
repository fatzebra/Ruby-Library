# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fat_zebra/version'

Gem::Specification.new do |s|
  s.name        = 'fat_zebra'
  s.version     = FatZebra::VERSION
  s.authors     = ['Fat Zebra']
  s.email       = ['support@fatzebra.com']
  s.homepage    = 'https://github.com/fatzebra/Ruby-Library'
  s.summary     = 'Fat Zebra payments gem - integrate your ruby app with Fat Zebra'
  s.description = 'Provides integration with the Fat Zebra internet payment gateway (www.fatzebra.com), including purchase, refund, auth, capture and recurring billing functionality.'

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = s.homepage

  s.files         = Dir.glob('lib/**/*') + %w[README.md fat_zebra.gemspec]
  s.require_paths = ['lib']

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
