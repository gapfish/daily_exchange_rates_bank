# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'webmock/rspec'
require 'daily_exchange_rates_bank'

RSpec.configure do |c|
  c.order = :random
end
