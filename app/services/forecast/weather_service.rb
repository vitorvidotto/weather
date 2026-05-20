module Forecast
  class WeatherService
    def initialize(client: WeatherApiClient.new)
      @client = client
    end

    def fetch(zip_code)
      @client.forecast(zip_code)
    end
  end
end
