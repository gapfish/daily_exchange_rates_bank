# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Money::RatesStore::StoreWithDateSupport do
  let(:store) { described_class.new }

  describe '#add_rate and #get_rate' do
    it 'stores rate in memory' do
      expect(store.add_rate('CHF', 'EUR', 0.9)).to eq 0.9
      expect(store.add_rate('USD', 'EUR', 0.8)).to eq 0.8

      expect(store.get_rate('CHF', 'EUR')).to eq 0.9
      expect(store.get_rate('USD', 'EUR')).to eq 0.8
    end

    it 'supports date parameter' do
      date = Date.parse('2019-09-19')
      rate = 0.9115770283

      expect(store.add_rate('CHF', 'EUR', rate, date)).to eq rate
      expect(store.get_rate('CHF', 'EUR', date)).to eq rate
    end
  end

  describe '#each_rate' do
    it 'iterates over added rates' do
      store.add_rate('CHF', 'EUR', 0.9, '2019-09-19')
      store.add_rate('USD', 'EUR', 0.8, '2019-08-01')
      store.add_rate('EUR', 'USD', 1.1)

      expect(store.each_rate).to be_kind_of(Enumerator)

      expect { |b| store.each_rate(&b) }.to yield_successive_args(
        ['CHF', 'EUR', 0.9, Date.new(2019, 9, 19)],
        ['USD', 'EUR', 0.8, Date.new(2019, 8, 1)],
        ['EUR', 'USD', 1.1, nil]
      )
    end
  end
end
