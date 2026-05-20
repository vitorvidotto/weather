module Forecast
  class WeatherApiClient
    BASE_URL = 'https://api.weatherapi.com/v1'.freeze
    FORECAST_DAYS = 3

    class ApiError < StandardError; end
    class ZipNotFoundError < StandardError; end

    def forecast(zip_code)
      response = connection.get('/v1/forecast.json') do |req|
        req.params.merge!(forecast_params(zip_code))
      end
      handle_response(response, zip_code)
    rescue Faraday::Error => e
      raise ApiError, "WeatherAPI request failed: #{e.message}"
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.response :json
      end
    end

    def forecast_params(zip_code)
      { 'key' => api_key, 'q' => zip_code, 'days' => FORECAST_DAYS, 'aqi' => 'no', 'alerts' => 'no' }
    end

    def api_key
      ENV.fetch('WEATHER_API_KEY')
    end

    def handle_response(response, zip_code)
      case response.status
      when 200
        Parsers::WeatherApiResponse.new(response.body, zip_code: zip_code).parse
      when 400
        raise ZipNotFoundError, 'ZIP code not found'
      else
        raise ApiError, "WeatherAPI returned #{response.status}"
      end
    end
  end
end
