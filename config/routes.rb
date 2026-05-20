Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "forecasts#index"
  get "forecast", to: "forecasts#show", as: :forecast
end
