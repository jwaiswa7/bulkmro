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

every(1.day, 'refresh_calculated_totals', :at => '03:00') do
  service = Services::Overseers::Inquiries::RefreshCalculatedTotals.new
  service.call
end

every(20.minutes, 'refresh_smart_queue', :at => '06:00') do
  service = Services::Overseers::Inquiries::RefreshSmartQueue.new
  service.call
end

every(1.day, 'refresh_indices', :at => '06:00') do
  ProductsIndex.reset!
  InquiriesIndex.reset!
  SalesOrdersIndex.reset!
  SalesQuotesIndex.reset!
  SalesInvoicesIndex.reset!
  SalesShipmentsIndex.reset!
  PurchaseOrdersIndex.reset!
end

every(1.hour, 'adjust_dynos') do
  Services::Shared::Heroku::DynoAdjuster.new
end

every(1.day, 'set_slack_ids', :at => '07:00') do
  service = Services::Overseers::Slack::SetSlackIds.new
  service.call
end