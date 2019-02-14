require 'clockwork'
include Clockwork
require './config/boot'
require './config/environment'
require 'active_support/time'

handler do |job, time|
  puts "Running #{job}, at #{time}"
end

every(1.day, 'log_currency_rates', at: '06:00') do
  service = Services::Overseers::Currencies::LogCurrencyRates.new
  service.call
end

every(1.day, 'refresh_calculated_totals', at: '03:00') do
  service = Services::Overseers::Inquiries::RefreshCalculatedTotals.new
  service.call
end

every(20.minutes, 'refresh_smart_queue') do
  service = Services::Overseers::Inquiries::RefreshSmartQueue.new
  service.call
end

every(30.minutes, 'update_admin_dashboard_cache') do
    service = Services::Overseers::Dashboards::Admin.new
    service.call
end

every(1.day, 'flush_unavailable_images', :at => '03:30') do
  service = Services::Customers::CustomerProducts::FlushUnavailableImages.new
  service.call
end

every(1.hour, 'generate_exports_hourly') do
  Services::Overseers::Exporters::GenerateExportsHourly.new
end

every(1.day, 'generate_exports_daily', at: '05:00') do
  Services::Overseers::Exporters::GenerateExportsDaily.new
end

every(1.day, 'refresh_indices', at: '06:00') do
  Services::Shared::Chewy::RefreshIndices.new
end

every(1.hour, 'adjust_dynos') do
  Services::Shared::Heroku::DynoAdjuster.new
end if Rails.env.production?

every(1.day, 'set_slack_ids', at: '07:00') do
  service = Services::Overseers::Slack::SetSlackIds.new
  service.call
end

every(1.day, 'gcloud_run_backups', at: '23:00') do
  service = Services::Shared::Gcloud::RunBackups.new
  service.call
end if Rails.env.production?

every(1.day, 'gcloud_run_backups_alt', at: '23:30') do
  service = Services::Shared::Gcloud::RunBackups.new(send_chat_message: false)
  service.call
end if Rails.env.production?

# every(1.month, 'product_inventory_update', :at => '05:00') do
#   service = Services::Resources::Products::UpdateInventory.new
#   service.call
# end if Rails.env.production?

every(1.day, 'inquiry_product_inventory_update', at: '02:00') do
  service = Services::Resources::Products::UpdateRecentInquiryProductInventory.new
  service.call
end if Rails.env.production?

every(1.day, 'remote_unwanted_requests', at: '22:00') do
  service = Services::Overseers::RequestCronJobs::RemoveRequestCronJob.new
  service.call
end if Rails.env.production?

every(1.day, 'resync_failed_requests', at: '03:00') do
  service = Services::Overseers::FailedRemoteRequests::Resync.new
  service.call
end if Rails.env.production?

every(1.day, 'resync_requests_status', at: '06:00') do
  service = Services::Overseers::FailedRemoteRequests::Resync.new
  service.verify
end if Rails.env.production?
