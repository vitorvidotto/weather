module Forecast
  class CacheService
    TTL = 30.minutes

    def initialize(weather_service: WeatherService.new, logger: Rails.logger)
      @weather_service = weather_service
      @logger = logger
    end

    def fetch(zip_code)
      key = cache_key(zip_code)
      cached = read_from_cache(key)

      if cached
        cached.merge(from_cache: true)
      else
        result = @weather_service.fetch(zip_code)
        payload = { result: result, cached_at: Time.current, from_cache: false }
        write_to_cache(key, payload)
        payload
      end
    end

    private

    def cache_key(zip_code)
      "forecast:#{zip_code}"
    end

    def read_from_cache(key)
      Rails.cache.read(key)
    rescue StandardError => e
      @logger.error("[CacheService] Failed to read from cache: #{e.message}")
      nil
    end

    def write_to_cache(key, payload)
      Rails.cache.write(key, payload, expires_in: TTL)
    rescue StandardError => e
      @logger.error("[CacheService] Failed to write to cache: #{e.message}")
    end
  end
end
