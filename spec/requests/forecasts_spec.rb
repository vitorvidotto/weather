require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
  let(:weather_result) do
    Forecast::Parsers::WeatherApiResponse::WeatherResult.new(
      zip_code: '10011',
      location: 'New York, New York',
      current: Forecast::Parsers::WeatherApiResponse::CurrentConditions.new(
        temp_f: 68.0,
        temp_c: 20.0,
        condition: 'Partly cloudy',
        humidity: 60,
        wind_mph: 8.0,
        feels_like_f: 66.0,
        icon: '//cdn.weatherapi.com/weather/64x64/day/116.png'
      ),
      forecast: [
        Forecast::Parsers::WeatherApiResponse::DailyForecast.new(
          date: Date.today,
          high_f: 72.0,
          low_f: 58.0,
          condition: 'Partly cloudy',
          icon: '//cdn.weatherapi.com/weather/64x64/day/116.png',
          chance_of_rain: 20
        )
      ]
    )
  end

  let(:payload) { { result: weather_result, cached_at: Time.current, from_cache: false } }

  describe 'GET /' do
    it 'renders the search form' do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Weather Forecast')
      expect(response.body).to include('Get Forecast')
    end
  end

  describe 'GET /forecast' do
    context 'when address is blank' do
      it 'redirects to root' do
        get forecast_path, params: { address: '' }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when address resolves successfully' do
      before do
        allow_any_instance_of(Forecast::GeocodingService)
          .to receive(:zip_for).and_return('10011')
        allow_any_instance_of(Forecast::CacheService)
          .to receive(:fetch).and_return(payload)
      end

      it 'returns 200' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response).to have_http_status(:ok)
      end

      it 'displays the location' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response.body).to include('New York, New York')
      end

      it 'displays current temperature' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response.body).to include('68')
      end

      it 'displays the live indicator when not from cache' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response.body).to include('Live')
      end

      context 'when result is from cache' do
        let(:payload) { { result: weather_result, cached_at: 10.minutes.ago, from_cache: true } }

        it 'displays the cached indicator' do
          get forecast_path, params: { address: '47 W 13th St, New York, NY' }
          expect(response.body).to include('Cached')
        end
      end
    end

    context 'when address cannot be geocoded' do
      before do
        allow_any_instance_of(Forecast::GeocodingService)
          .to receive(:zip_for).and_raise(Forecast::GeocodingClient::AddressNotFoundError)
      end

      it 'renders the error page' do
        get forecast_path, params: { address: 'nowhere' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('could not find a US ZIP code')
      end
    end

    context 'when the weather API is unavailable' do
      before do
        allow_any_instance_of(Forecast::GeocodingService)
          .to receive(:zip_for).and_return('10011')
        allow_any_instance_of(Forecast::CacheService)
          .to receive(:fetch).and_raise(Forecast::WeatherApiClient::ApiError)
      end

      it 'renders the error page' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('temporarily unavailable')
      end
    end

    context 'when the ZIP code is not found in the weather API' do
      before do
        allow_any_instance_of(Forecast::GeocodingService)
          .to receive(:zip_for).and_return('10011')
        allow_any_instance_of(Forecast::CacheService)
          .to receive(:fetch).and_raise(Forecast::WeatherApiClient::ZipNotFoundError)
      end

      it 'renders the error page' do
        get forecast_path, params: { address: '47 W 13th St, New York, NY' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('No weather data found')
      end
    end
  end
end
