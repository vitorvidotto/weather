require 'rails_helper'

RSpec.describe Forecast::WeatherApiClient do
  subject(:client) { described_class.new }

  let(:zip_code) { '90210' }
  let(:forecast_url) { /api\.weatherapi\.com/ }

  describe '#forecast' do
    context 'with a recorded API response', vcr: { cassette_name: 'weather_api_forecast_90210' } do
      let(:result) { client.forecast(zip_code) }

      it 'returns a WeatherResult' do
        expect(result).to be_a(Forecast::Parsers::WeatherApiResponse::WeatherResult)
      end

      it 'returns the zip code' do
        expect(result.zip_code).to eq('90210')
      end

      it 'returns the location name' do
        expect(result.location).to eq('Beverly Hills, California')
      end

      it 'returns current temperature' do
        expect(result.current.temp_f).to eq(72.0)
      end

      it 'returns current condition' do
        expect(result.current.condition).to eq('Sunny')
      end

      it 'returns 3 forecast days' do
        expect(result.forecast.length).to eq(3)
      end

      it 'returns correct high for day 1' do
        expect(result.forecast[0].high_f).to eq(76.0)
      end

      it 'returns correct rain chance for day 3' do
        expect(result.forecast[2].chance_of_rain).to eq(75)
      end
    end

    context 'when the ZIP code is not found' do
      before do
        stub_request(:get, forecast_url)
          .to_return(status: 400, body: { error: { message: 'No matching location found' } }.to_json)
      end

      it 'raises ZipNotFoundError' do
        expect { client.forecast(zip_code) }.to raise_error(Forecast::WeatherApiClient::ZipNotFoundError)
      end
    end

    context 'when the API returns a server error' do
      before do
        stub_request(:get, forecast_url)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises ApiError' do
        expect { client.forecast(zip_code) }.to raise_error(Forecast::WeatherApiClient::ApiError)
      end
    end

    context 'when the network request fails' do
      before do
        stub_request(:get, forecast_url)
          .to_raise(Faraday::ConnectionFailed.new('connection refused'))
      end

      it 'raises ApiError' do
        expect { client.forecast(zip_code) }.to raise_error(Forecast::WeatherApiClient::ApiError)
      end
    end
  end
end
