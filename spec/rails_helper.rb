require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
ENV['WEATHER_API_KEY'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'vcr'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.use_active_record = false
  config.filter_rails_from_backtrace!
  config.after { WebMock.reset! }
end
