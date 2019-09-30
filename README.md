# DailyExchangeRatesBank

[![Codeship Status for gapfish/daily_exchange_rates_bank](https://app.codeship.com/projects/4d5d2f00-c367-0137-d12d-621d2c7e26d1/status?branch=master)](https://app.codeship.com/projects/366592)

A bank for the money gem that determines exchange rates for any desired date.
Missing exchange rates are fetched from exchangeratesapi.io

## Installation

Add this line to your application's Gemfile:

`gem 'daily_exchange_rates_bank'`

and then execute:

`$ bundle`

Or install it yourself:

`$ gem install daily_exchange_rates_bank`

## Usage

```ruby
require 'daily_exchange_rates_bank'

bank = DailyExchangeRatesBank.new
Money.default_bank = bank

Money.new(100, 'EUR').exchange_to('USD')  # => Money.new(109, 'USD')
bank.get_rate('EUR', 'USD') # => 1.0935

date = Date.new(2019, 7, 1)
bank.exchange(100, 'EUR', 'USD', date) # => Money.new(113, 'USD')
bank.exchange_with(Money.new(100, 'EUR'), 'USD', date) # => Money.new(113, 'USD')
```

If you are using the [money-rails](https://github.com/RubyMoney/money-rails)
gem, you can set the default_bank in `config/initializers/money.rb`:

```ruby
MoneyRails.configure do |config|
  config.default_bank = DailyExchangeRatesBank.new

  # remaining config
end
```
