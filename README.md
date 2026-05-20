# Weather Forecast

A Ruby on Rails application that accepts a US address, resolves it to a ZIP code, and displays a 3-day weather forecast with current conditions. Forecast data is cached in Redis for 30 minutes per ZIP code.

## Features

- Address input with geocoding to extract US ZIP codes
- Current temperature, feels like, humidity, and wind speed
- 3-day forecast with high/low temperatures and chance of rain
- Redis caching with a 30-minute TTL per ZIP code
- Cache indicator showing whether data is live or cached, with a timestamp
- Graceful error pages for unresolvable addresses and API failures
- Redis failure bypass, the app falls through to a live API call if Redis is unavailable

## Tech Stack

- **Ruby on Rails 8**: no database, stateless by design
- **WeatherAPI.com**: current conditions and 3-day forecast
- **Geocoder gem**: address-to-ZIP resolution via OpenStreetMap Nominatim
- **Redis**: forecast caching
- **Tailwind CSS**: styling
- **Docker + Docker Compose**: containerised local development
- **RSpec + WebMock + VCR**: unit, integration, and recorded HTTP tests
- **Rubocop + Brakeman + Bundler Audit**: code quality and security

## Architecture

```
app/
  clients/forecast/
    weather_api_client.rb        # HTTP calls to WeatherAPI.com
    geocoding_client.rb          # Geocoder gem wrapper
    parsers/
      weather_api_response.rb    # Parses raw API response into typed structs
  services/forecast/
    geocoding_service.rb         # Address → ZIP with US format validation
    weather_service.rb           # Delegates to client, returns WeatherResult
    cache_service.rb             # Redis read/write with 30-min TTL
```

**Request flow:**
```
Address input
  → GeocodingService extracts US ZIP code
    → CacheService checks Redis
      → Hit: return cached data + timestamp
      → Miss: WeatherService fetches API → cache → return
  → Render forecast view
```

The client layer owns the full HTTP lifecycle including response parsing. Services orchestrate clients and apply business logic.

## Setup

### Prerequisites

- Ruby 3.3+
- Redis (or Docker)
- A free [WeatherAPI.com](https://www.weatherapi.com) API key

### Local development

```bash
git clone <repo-url>
cd weather_forecast
bundle install
cp .env.example .env
# Edit .env and add your WEATHER_API_KEY
redis-server &
export $(cat .env | xargs) && bin/rails server
```

Visit `http://localhost:3000`.

### Docker

```bash
cp .env.example .env
# Edit .env and add your WEATHER_API_KEY
docker-compose up --build
```

Visit `http://localhost:3000`.

## Environment Variables

| Variable | Description |
|---|---|
| `WEATHER_API_KEY` | WeatherAPI.com API key (required) |
| `REDIS_URL` | Redis connection URL (default: `redis://localhost:6379/0`) |

## Running Tests

```bash
bundle exec rspec
```

## Linting and Security

```bash
bundle exec rubocop          # Style
bundle exec brakeman         # Security static analysis
bundle exec bundler-audit    # Dependency vulnerability check
```
