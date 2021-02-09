# frozen_string_literal: true

require 'date'

class Money
  module RatesStore
    # Class for thread-safe storage of exchange rates per date.
    class StoreWithDateSupport < Money::RatesStore::Memory
      INDEX_DATE_SEPARATOR = '_ON_'

      def add_rate(currency_iso_from, currency_iso_to, rate, date = nil)
        guard.synchronize do
          rates[rate_key_for(currency_iso_from, currency_iso_to, date)] = rate
        end
      end

      def get_rate(currency_iso_from, currency_iso_to, date = nil)
        guard.synchronize do
          rates[rate_key_for(currency_iso_from, currency_iso_to, date)]
        end
      end

      # Iterate over exchange rate tuples
      #
      # @yieldparam iso_from [String] Currency ISO string.
      # @yieldparam iso_to [String] Currency ISO string.
      # @yieldparam rate [String] Exchange rate.
      # @yieldparam date [Date] Date of the exchange rate. Nil for current rate.
      #
      # @return [Enumerator]
      # @example
      #   store.each_rate do |iso_from, iso_to, rate, date|
      #     puts [iso_from, iso_to, rate, date].join
      #   end
      def each_rate(&_block)
        return to_enum(:each_rate) unless block_given?

        guard.synchronize do
          rates.each do |key, rate|
            iso_from, iso_to = key.split(INDEX_KEY_SEPARATOR)
            iso_to, date = iso_to.split(INDEX_DATE_SEPARATOR)
            date = Date.parse(date) if date
            yield iso_from, iso_to, rate, date
          end
        end
      end

      private

      def rate_key_for(currency_iso_from, currency_iso_to, date = nil)
        key = [currency_iso_from, currency_iso_to].
          join(Memory::INDEX_KEY_SEPARATOR)
        key = [key, date.to_s].join(INDEX_DATE_SEPARATOR) if date
        key.upcase
      end
    end
  end
end
