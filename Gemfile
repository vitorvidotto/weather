source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "puma", ">= 5.0"
gem "tailwindcss-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "thruster", require: false

# HTTP client
gem "faraday", "~> 2.0"

# Geocoding
gem "geocoder", "~> 1.8"

# Redis cache store
gem "redis", "~> 5.0"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 7.0"
  gem "webmock", "~> 3.23"
  gem "vcr", "~> 6.0"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
end

group :development do
  gem "web-console"
end
