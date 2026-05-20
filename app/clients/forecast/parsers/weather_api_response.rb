module Forecast
  module Parsers
    class WeatherApiResponse
      CurrentConditions = Data.define(:temp_f, :temp_c, :condition, :humidity, :wind_mph, :feels_like_f, :icon)
      DailyForecast = Data.define(:date, :high_f, :low_f, :condition, :icon, :chance_of_rain)
      WeatherResult = Data.define(:zip_code, :location, :current, :forecast)

      def initialize(raw, zip_code:)
        @raw = raw
        @zip_code = zip_code
      end

      def parse
        WeatherResult.new(
          zip_code: @zip_code,
          location: parse_location,
          current: parse_current,
          forecast: parse_forecast
        )
      end

      private

      def parse_location
        loc = @raw['location']
        "#{loc['name']}, #{loc['region']}"
      end

      def parse_current
        c = @raw['current']
        CurrentConditions.new(
          temp_f: c['temp_f'],
          temp_c: c['temp_c'],
          condition: c.dig('condition', 'text'),
          humidity: c['humidity'],
          wind_mph: c['wind_mph'],
          feels_like_f: c['feelslike_f'],
          icon: c.dig('condition', 'icon')
        )
      end

      def parse_forecast
        @raw.dig('forecast', 'forecastday').map do |day|
          DailyForecast.new(
            date: Date.parse(day['date']),
            high_f: day.dig('day', 'maxtemp_f'),
            low_f: day.dig('day', 'mintemp_f'),
            condition: day.dig('day', 'condition', 'text'),
            icon: day.dig('day', 'condition', 'icon'),
            chance_of_rain: day.dig('day', 'daily_chance_of_rain')
          )
        end
      end
    end
  end
end
