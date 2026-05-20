VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<WEATHER_API_KEY>') { ENV.fetch('WEATHER_API_KEY', 'test') }
  config.default_cassette_options = { record: :none }
end
