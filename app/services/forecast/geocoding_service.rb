module Forecast
  class GeocodingService
    US_ZIP_FORMAT = /\A\d{5}\z/

    def initialize(client: GeocodingClient.new)
      @client = client
    end

    def zip_for(address)
      zip = @client.zip_for(address)
      raise GeocodingClient::AddressNotFoundError, 'Address did not resolve to a US ZIP code' unless us_zip?(zip)

      zip
    end

    private

    def us_zip?(zip)
      US_ZIP_FORMAT.match?(zip.to_s)
    end
  end
end
