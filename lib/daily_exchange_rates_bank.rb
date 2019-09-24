# frozen_string_literal: true

require 'money'
require 'money/rates_store/store_with_date_support'
require 'daily_exchange_rates_bank/exchange_rates_api_client'

# Class for aiding in exchanging money between different currencies.
class DailyExchangeRatesBank < Money::Bank::VariableExchange
  SERIALIZER_DATE_SEPARATOR = '_ON_'

  def initialize(store = Money::RatesStore::StoreWithDateSupport.new, &block)
    super(store, &block)
  end

  def get_rate(from, to, date = nil)
    store.get_rate(::Money::Currency.wrap(from).iso_code,
                   ::Money::Currency.wrap(to).iso_code,
                   date)
  end

  def set_rate(from, to, rate, date = nil)
    store.add_rate(::Money::Currency.wrap(from).iso_code,
                   ::Money::Currency.wrap(to).iso_code,
                   rate,
                   date)
  end

  def rates
    store.each_rate.each_with_object({}) do |(from, to, rate, date), hash|
      key = [from, to].join(SERIALIZER_SEPARATOR)
      key = [key, date.to_s].join(SERIALIZER_DATE_SEPARATOR) if date
      hash[key] = rate
    end
  end

  def exchange(cents, from_currency, to_currency, date = nil)
    exchange_with(Money.new(cents, from_currency), to_currency, date)
  end

  def exchange_with(from, to_currency, date = nil)
    to_currency = ::Money::Currency.wrap(to_currency)
    return from if from.currency == to_currency

    rate = get_rate(from.currency, to_currency, date)

    rate ||= rate_from_exchange_rates_api(from.currency, to_currency, date)

    fractional = calculate_fractional(from, to_currency, rate)
    Money.new(fractional, to_currency)
  end

  private

  def rate_from_exchange_rates_api(from_currency, to_currency, date)
    api_client = DailyExchangeRatesBank::ExchangeRatesApiClient.new
    rates = api_client.exchange_rates(from: from_currency.iso_code,
                                      to: [to_currency.iso_code],
                                      date: (date || Date.today))
    rate = rates[to_currency.iso_code]

    set_rate(from_currency, to_currency, rate, date)

    rate
  end

  def calculate_fractional(from, to_currency, rate)
    BigDecimal(rate.to_s) * BigDecimal(from.fractional.to_s) / (
      BigDecimal(from.currency.subunit_to_unit.to_s) /
      BigDecimal(to_currency.subunit_to_unit.to_s)
    )
  end
end
