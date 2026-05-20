require 'rails_helper'

RSpec.describe Forecast::Parsers::WeatherApiResponse do
  subject(:result) { described_class.new(raw, zip_code: '90210').parse }

  let(:raw) do
    {
      'location' => { 'name' => 'Beverly Hills', 'region' => 'California' },
      'current' => {
        'temp_f' => 72.1,
        'temp_c' => 22.3,
        'feelslike_f' => 70.5,
        'humidity' => 60,
        'wind_mph' => 5.0,
        'condition' => { 'text' => 'Sunny', 'icon' => '//cdn.weatherapi.com/weather/64x64/day/113.png' }
      },
      'forecast' => {
        'forecastday' => [
          {
            'date' => '2026-05-19',
            'day' => {
              'maxtemp_f' => 78.0,
              'mintemp_f' => 60.0,
              'daily_chance_of_rain' => 10,
              'condition' => { 'text' => 'Sunny', 'icon' => '//cdn.weatherapi.com/weather/64x64/day/113.png' }
            }
          },
          {
            'date' => '2026-05-20',
            'day' => {
              'maxtemp_f' => 75.0,
              'mintemp_f' => 58.0,
              'daily_chance_of_rain' => 30,
              'condition' => { 'text' => 'Partly Cloudy', 'icon' => '//cdn.weatherapi.com/weather/64x64/day/116.png' }
            }
          }
        ]
      }
    }
  end

  it 'parses the zip code' do
    expect(result.zip_code).to eq('90210')
  end

  it 'parses the location name' do
    expect(result.location).to eq('Beverly Hills, California')
  end

  describe 'current conditions' do
    subject(:current) { result.current }

    it { expect(current.temp_f).to eq(72.1) }
    it { expect(current.temp_c).to eq(22.3) }
    it { expect(current.condition).to eq('Sunny') }
    it { expect(current.humidity).to eq(60) }
    it { expect(current.wind_mph).to eq(5.0) }
    it { expect(current.feels_like_f).to eq(70.5) }
  end

  describe 'forecast days' do
    it 'parses the correct number of days' do
      expect(result.forecast.length).to eq(2)
    end

    it 'parses the first day correctly' do
      day = result.forecast.first
      expect(day.date).to eq(Date.parse('2026-05-19'))
      expect(day.high_f).to eq(78.0)
      expect(day.low_f).to eq(60.0)
      expect(day.chance_of_rain).to eq(10)
      expect(day.condition).to eq('Sunny')
    end
  end
end
