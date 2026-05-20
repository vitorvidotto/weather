class ForecastsController < ApplicationController
  def index; end

  def show
    address = params[:address].to_s.strip
    return redirect_to root_path, alert: 'Please enter an address.' if address.blank?

    @payload = fetch_forecast(address)
    @result = @payload[:result]
  rescue Forecast::GeocodingClient::AddressNotFoundError
    render_error('We could not find a US ZIP code for that address. Please try a more specific address.')
  rescue Forecast::WeatherApiClient::ZipNotFoundError
    render_error('No weather data found for that location.')
  rescue Forecast::WeatherApiClient::ApiError
    render_error('The weather service is temporarily unavailable. Please try again later.')
  rescue StandardError
    render_error('An unexpected error occurred.')
  end

  private

  def fetch_forecast(address)
    zip_code = Forecast::GeocodingService.new.zip_for(address)
    Forecast::CacheService.new.fetch(zip_code)
  end

  def render_error(message)
    @error = message
    render :error, status: :unprocessable_content
  end
end
