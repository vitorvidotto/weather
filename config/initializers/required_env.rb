unless ENV['SECRET_KEY_BASE_DUMMY']
  required_keys = %w[WEATHER_API_KEY]
  missing = required_keys.reject { |key| ENV[key].present? }
  raise "Missing required environment variables: #{missing.join(', ')}" if missing.any?
end
