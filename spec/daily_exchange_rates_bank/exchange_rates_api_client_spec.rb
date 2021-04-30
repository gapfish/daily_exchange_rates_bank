# frozen_string_literal: true

require 'spec_helper'
require 'daily_exchange_rates_bank/exchange_rates_api_client'

RSpec.describe DailyExchangeRatesBank::ExchangeRatesApiClient do
  describe '#exchange_rates', :webmock do
    it 'shows three select exchange rates of EUR by default' do
      json_response = {
        'rates' => {
          'CHF' => 1.0934, 'USD' => 1.1003, 'GBP' => 0.89133
        },
        'base' => 'EUR',
        'date' => '2019-09-11'
      }.to_json
      stub_request(:get, "https://api.frankfurter.app/#{Date.today}").
        with(query: 'base=EUR&symbols=USD,GBP,CHF').
        to_return(status: 200, body: json_response)

      rates = described_class.new.exchange_rates
      expect(rates).to eq(
        'USD' => 1.1003,
        'GBP' => 0.89133,
        'CHF' => 1.0934
      )
    end
  end
end
