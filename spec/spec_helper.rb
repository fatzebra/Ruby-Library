require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'rspec'
require 'vcr'
require 'webmock/rspec'
require 'date'

require 'fat_zebra'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

##
# Remove ID from the URL
uri_ignoring_trailing_id = lambda do |request_1, request_2|
  uri1, uri2 = request_1.uri, request_2.uri
  regexp_trail_id = %r(/\d+\-[A-Z]\-.*\/)
  regexp_trail_id = uri1.match(regexp_trail_id) ? regexp_trail_id : %r(/\d+\-[A-Z]\-.*\z)
  if uri1.match(regexp_trail_id)
    r1_without_id = uri1.gsub(regexp_trail_id, "")
    r2_without_id = uri2.gsub(regexp_trail_id, "")
    uri1.match(regexp_trail_id) && uri2.match(regexp_trail_id) && r1_without_id == r2_without_id
  else
    VCR.request_matchers.uri_without_param(:to, :from)
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = { match_requests_on: [:method, uri_ignoring_trailing_id] }
end

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec

  config.include_context 'payloads'

  config.before(:each) do
    FatZebra.configure do |config|
      config.username  = 'TEST'
      config.token     = 'TEST'
      config.gateway   = 'gateway.sandbox.fatzebra.com.au'
      config.test_mode = true
    end
  end

end
