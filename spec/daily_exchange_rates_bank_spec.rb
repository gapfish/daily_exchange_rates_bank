# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DailyExchangeRatesBank do
  let(:bank) { DailyExchangeRatesBank.new }

  describe '#store' do
    it 'defaults to memory store with date support' do
      expect(bank.store).to be_a(Money::RatesStore::StoreWithDateSupport)
    end
  end

  describe '#set_rate' do
    it 'delegates to store#add_rate' do
      expect(bank.store).to receive(:add_rate).with('CHF', 'EUR', 0.9, nil).
        and_return(0.9)

      expect(bank.set_rate('CHF', 'EUR', 0.9)).to eq 0.9
    end

    it 'passes on date parameter' do
      date = Date.new(2019, 9, 20)
      expect(bank.store).to receive(:add_rate).with('CHF', 'EUR', 0.9, date).
        and_return(0.9)

      expect(bank.set_rate('CHF', 'EUR', 0.9, date)).to eq 0.9
    end
  end

  describe '#get_rate' do
    it 'delegates to store#get_rate' do
      expect(bank.store).to receive(:get_rate).with('CHF', 'EUR', nil).
        and_return(0.9)

      expect(bank.get_rate('CHF', 'EUR')).to eq 0.9
    end

    it 'passes on date parameter' do
      date = Date.new(2019, 9, 20)
      expect(bank.store).to receive(:get_rate).with('CHF', 'EUR', date).
        and_return(0.8)

      expect(bank.get_rate('CHF', 'EUR', date)).to eq 0.8
    end
  end

  describe '#rates' do
    it 'returns all defined rates from store' do
      bank.store.add_rate('CHF', 'EUR', 0.9)
      bank.store.add_rate('CHF', 'EUR', 0.91, '2019-09-19')
      bank.store.add_rate('USD', 'EUR', 0.789, '2019-09-01')

      expect(bank.rates).to eq('CHF_TO_EUR' => 0.9,
                               'CHF_TO_EUR_ON_2019-09-19' => 0.91,
                               'USD_TO_EUR_ON_2019-09-01' => 0.789)
    end
  end

  describe '#exchange' do
    it 'delegates to exchange_with' do
      cents = rand(1000)
      from_currency = 'CHF'
      to_currency = 'EUR'
      date = Date.new(2019, 9, 20)
      expect(bank).to receive(:exchange_with).
        with(Money.new(cents, from_currency), to_currency, date)

      bank.exchange(cents, from_currency, to_currency, date)
    end
  end

  describe '#exchange_with' do
    context 'when exchange rate is in store' do
      before do
        bank.store.add_rate('CHF', 'EUR', 0.921)
      end

      it 'accepts string currency parameter' do
        expect { bank.exchange_with(Money.new(100, 'CHF'), 'EUR') }.
          to_not raise_exception
      end

      it 'accepts string currency parameter' do
        expect do
          bank.exchange_with(Money.new(100, 'CHF'), Money::Currency.wrap('EUR'))
        end.to_not raise_error
      end

      it 'raises UnknownCurrency error when an unknown currency is passed' do
        expect { bank.exchange_with(Money.new(100, 'EUR'), 'XYZ') }.
          to raise_error(Money::Currency::UnknownCurrency)
      end

      it 'uses rate from store and truncates digits' do
        expect(bank.exchange_with(Money.new(100, 'CHF'), 'EUR')).
          to eq Money.new(92, 'EUR')
      end

      it 'considers differences in subunit-to-unit-ratios' do
        bank.store.add_rate('EUR', 'JPY', 118.07)

        expect(bank.exchange_with(Money.new(1000, 'EUR'), 'JPY')).
          to eq Money.new(1181, 'JPY')
      end

      it 'supports exchange for specific dates' do
        date = Date.new(2019, 9, 20)
        bank.store.add_rate('CHF', 'EUR', 0.987, date)

        expect(bank.exchange_with(Money.new(100, 'CHF'), 'EUR', date)).
          to eq Money.new(99, 'EUR')
      end
    end

    context 'when exchange rate is not in store' do
      let(:api_client) do
        instance_double(DailyExchangeRatesBank::ExchangeRatesApiClient)
      end

      it 'fetches exchange rate from api.frankfurter.app and stores it' do
        date = Date.new(2019, 9, 21)
        expect(DailyExchangeRatesBank::ExchangeRatesApiClient).to receive(:new).
          and_return(api_client)
        expect(api_client).to receive(:exchange_rates).
          with(from: 'CHF', to: ['EUR'], date: date).
          and_return('EUR' => 0.9139097057)

        expect(bank.exchange_with(Money.new(1000, 'CHF'), 'EUR', date)).
          to eq Money.new(914, 'EUR')
        expect(bank.get_rate('CHF', 'EUR', date)).to eq 0.9139097057
      end

      context 'without specified date' do
        it 'fetches latest exchange rate' do
          expect(DailyExchangeRatesBank::ExchangeRatesApiClient).
            to receive(:new).
            and_return(api_client)
          expect(api_client).to receive(:exchange_rates).
            with(from: 'EUR', to: ['USD'], date: Date.today).
            and_return('USD' => 1.091234)

          expect(bank.exchange_with(Money.new(100, 'EUR'), 'USD')).
            to eq Money.new(109, 'USD')
          expect(bank.get_rate('EUR', 'USD')).to eq 1.091234
        end
      end
    end
  end
end
