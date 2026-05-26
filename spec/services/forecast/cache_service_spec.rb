require 'rails_helper'

RSpec.describe Forecast::CacheService do
  subject(:service) { described_class.new(weather_service: weather_service, logger: logger) }

  let(:weather_service) { instance_double(Forecast::WeatherService) }
  let(:logger) { instance_double(ActiveSupport::Logger, error: nil) }
  let(:result) { instance_double(Forecast::Parsers::WeatherApiResponse::WeatherResult) }

  before { Rails.cache.clear }

  describe '#fetch' do
    context 'when data is not cached' do
      before do
        allow(weather_service).to receive(:fetch).with('90210').and_return(result)
      end

      it 'calls the weather service' do
        service.fetch('90210')
        expect(weather_service).to have_received(:fetch).with('90210')
      end

      it 'returns from_cache: false' do
        payload = service.fetch('90210')
        expect(payload[:from_cache]).to be(false)
      end

      it 'includes a cached_at timestamp' do
        payload = service.fetch('90210')
        expect(payload[:cached_at]).to be_within(2.seconds).of(Time.current)
      end

      it 'stores the result in cache' do
        service.fetch('90210')
        expect(Rails.cache.read('forecast:90210')).not_to be_nil
      end
    end

    context 'when data is cached' do
      let(:cached_at) { 10.minutes.ago }

      before do
        allow(weather_service).to receive(:fetch)
        Rails.cache.write('forecast:90210', { result: result, cached_at: cached_at, from_cache: false },
                          expires_in: 30.minutes)
      end

      it 'does not call the weather service' do
        service.fetch('90210')
        expect(weather_service).not_to have_received(:fetch)
      end

      it 'returns from_cache: true' do
        payload = service.fetch('90210')
        expect(payload[:from_cache]).to be(true)
      end

      it 'returns the original cached_at timestamp' do
        payload = service.fetch('90210')
        expect(payload[:cached_at]).to be_within(1.second).of(cached_at)
      end
    end

    context 'when Redis is unavailable on read' do
      before do
        allow(Rails.cache).to receive(:read).and_raise(Redis::CannotConnectError, 'connection refused')
        allow(Rails.cache).to receive(:write)
        allow(weather_service).to receive(:fetch).with('90210').and_return(result)
      end

      it 'falls through to the weather service' do
        service.fetch('90210')
        expect(weather_service).to have_received(:fetch).with('90210')
      end

      it 'logs the error' do
        service.fetch('90210')
        expect(logger).to have_received(:error).with(/Failed to read from cache.*connection refused/i)
      end
    end

    context 'when Redis is unavailable on write' do
      before do
        allow(Rails.cache).to receive(:read).and_return(nil)
        allow(Rails.cache).to receive(:write).and_raise(Redis::CannotConnectError, 'connection refused')
        allow(weather_service).to receive(:fetch).with('90210').and_return(result)
      end

      it 'still returns the result' do
        payload = service.fetch('90210')
        expect(payload[:result]).to eq(result)
      end

      it 'logs the error' do
        service.fetch('90210')
        expect(logger).to have_received(:error).with(/Failed to write to cache.*connection refused/i)
      end
    end
  end
end
