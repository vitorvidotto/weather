Geocoder.configure(
  lookup: :nominatim,
  http_headers: { 'User-Agent' => 'WeatherForecastApp/1.0' },
  timeout: 10,
  units: :mi
)
