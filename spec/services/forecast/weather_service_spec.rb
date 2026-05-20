require 'rails_helper'

RSpec.describe Forecast::WeatherService do
  subject(:service) { described_class.new(client: client) }

  let(:client) { instance_double(Forecast::WeatherApiClient) }
  let(:weather_result) { instance_double(Forecast::Parsers::WeatherApiResponse::WeatherResult) }

  describe '#fetch' do
    before { allow(client).to receive(:forecast).with('90210').and_return(weather_result) }

    it 'delegates to the client and returns the result' do
      expect(service.fetch('90210')).to eq(weather_result)
    end
  end
end
