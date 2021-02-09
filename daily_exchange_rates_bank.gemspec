# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'daily_exchange_rates_bank'
  s.license       = 'GPL-3.0'
  s.version       = '1.0.0'
  s.date          = '2019-09-20'
  s.summary       = 'A bank for the money gem that determines exchange rates '\
    'for any desired date.'
  s.description   = 'This gem supports money conversions with '\
    'historic exchange rates. ' \
    'Missing exchange rates are fetched from exchangeratesapi.io'
  s.homepage      = 'https://github.com/gapfish/daily_exchange_rates_bank'
  s.authors       = ['Robert Aschenbrenner']
  s.files         = Dir.glob('lib/**/*') + %w[CHANGELOG.md LICENSE README.md]
  s.require_path  = 'lib'

  s.add_dependency 'money', '>= 6.14.0'

  s.add_development_dependency 'pry-byebug', '~> 3.7'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.74.0'
  s.add_development_dependency 'simplecov', '~> 0.17'
  s.add_development_dependency 'webmock', '~> 3.7'
end
