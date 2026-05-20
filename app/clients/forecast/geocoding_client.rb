module Forecast
  class GeocodingClient
    class AddressNotFoundError < StandardError; end

    US_COUNTRY_CODE = 'us'

    def zip_for(address)
      results = Geocoder.search(address, params: { countrycodes: US_COUNTRY_CODE })

      raise AddressNotFoundError, 'Could not resolve address to a US location' if results.empty?

      zip = results.first.postal_code

      raise AddressNotFoundError, 'Could not extract ZIP code from address' unless zip

      zip
    end
  end
end
