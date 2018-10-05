require 'clockwork'
include Clockwork
require './config/boot'
require './config/environment'
require 'active_support/time'

handler do |job, time|
  puts "Running #{job}, at #{time}"
end

# every(15.seconds, 'do_something') do
#
# end

# every(15.seconds, CurrencyRate.save_fx_rate)


every(1.day, CurrencyRate.save_fx_rate, :at => '06:00')