# frozen_string_literal: true

require 'open-uri'

class DailyExchangeRatesBank < Money::Bank::VariableExchange
  # Access api.frankfurter.app to fetch historic exchange rates
  class ExchangeRatesApiClient
    def exchange_rates(from: 'EUR', to: %w[USD GBP CHF], date: Date.today)
      api_url = ENV.fetch('RATES_API_URL', 'https://api.frankfurter.app/')
      uri = URI.parse(api_url)
      uri.path = "/#{date}/"
      uri.query = "base=#{from}&symbols=#{to.join(',')}"
      json_response = uri.read
      JSON.parse(json_response)['rates']
    end
  end
end
