require 'rails_helper'

RSpec.describe Forecast::GeocodingService do
  subject(:service) { described_class.new(client: client) }

  let(:client) { instance_double(Forecast::GeocodingClient) }

  describe '#zip_for' do
    context 'when the address resolves to a valid US ZIP' do
      before { allow(client).to receive(:zip_for).with('1600 Pennsylvania Ave, Washington DC').and_return('20500') }

      it 'returns the ZIP code' do
        expect(service.zip_for('1600 Pennsylvania Ave, Washington DC')).to eq('20500')
      end
    end

    context 'when the resolved ZIP is not a valid US format' do
      before { allow(client).to receive(:zip_for).and_return('SW1A1AA') }

      it 'raises AddressNotFoundError' do
        expect { service.zip_for('London') }.to raise_error(Forecast::GeocodingClient::AddressNotFoundError)
      end
    end

    context 'when the client raises AddressNotFoundError' do
      before { allow(client).to receive(:zip_for).and_raise(Forecast::GeocodingClient::AddressNotFoundError) }

      it 'propagates the error' do
        expect { service.zip_for('nowhere') }.to raise_error(Forecast::GeocodingClient::AddressNotFoundError)
      end
    end
  end
end
