# frozen_string_literal: true

require 'open-uri'

class DailyExchangeRatesBank < Money::Bank::VariableExchange
  # Access exchangeratesapi.io to fetch historic exchange rates
  class ExchangeRatesApiClient
    def exchange_rates(from: 'EUR', to: %w[USD GBP CHF], date: Date.today)
      uri = URI.parse('https://api.exchangeratesapi.io/')
      uri.path = "/#{date}/"
      uri.query = "base=#{from}&symbols=#{to.join(',')}"
      json_response = uri.read
      JSON.parse(json_response)['rates']
    end
  end
end
