require 'clockwork'
include Clockwork
require './config/boot'
require './config/environment'
require 'active_support/time'

handler do |job, time|
  puts "Running #{job}, at #{time}"
end

every(1.day, 'log_currency_rates', :at => '06:00') do
  service = Services::Overseers::Currencies::LogCurrencyRates.new
  service.call
end