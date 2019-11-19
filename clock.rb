require 'clockwork'
include Clockwork
require './config/boot'
require './config/environment'
require 'active_support/time'

handler do |job, time|
  Chewy.strategy(:atomic)
  puts "Running #{job}, at #{time}"
end

every(10.minutes, 'resync_remote_requests') do
  ResyncRemoteRequest.where('hits < 5').each do |resync_request|
    service = Services::Resources::Shared::ResyncFailedRequests.new(resync_request)
    service.call
  end
end

every(30.minutes, 'update_admin_dashboard_cache') do
  service = Services::Overseers::Dashboards::Admin.new
  service.call
end

every(60.minutes, 'refresh_smart_queue') do
  Chewy.strategy(:atomic) do
    service = Services::Overseers::Inquiries::RefreshSmartQueue.new
    service.call
  end
end

every(90.minutes, 'bible_upload') do
  Chewy.strategy(:atomic) do
    @bible_upload_queue = BibleUpload.where(status: 'Pending').first
    if @bible_upload_queue.present?
      service = Services::Overseers::Bible::BaseService.new
      service.call(@bible_upload_queue)
    end
  end
end

every(1.hour, 'adjust_dynos') do
  Services::Shared::Heroku::DynoAdjuster.new
end if Rails.env.production?

every(4.hour, 'generate_exports_hourly') do
  Chewy.strategy(:atomic) do
    Services::Overseers::Exporters::GenerateExportsHourly.new
  end
end

every(1.day, 'refresh_indices', at: '01:00') do
  # Chewy.strategy(:sidekiq) do
  #   Services::Shared::Chewy::RefreshIndices.new
  # end

  Dir[[Chewy.indices_path, '/*'].join()].map do |path|
    puts "Indexing #{path}"
    path.gsub('.rb', '').gsub('app/chewy/', '').classify.constantize.reset!
    puts "Indexed #{path}"
  end
end

# every(1.day, 'generate_exports_daily', at: '04:00') do
# Refactor exports and include status and find_each_with_batch in all exports
# Chewy.strategy(:atomic) do
#   Services::Overseers::Exporters::GenerateExportsDaily.new
# end
# end

every(1.day, 'purchase_order_reindex', at: '09:00') do
  puts 'For reindexing purchase orders'

  index_class = PurchaseOrdersIndex
  if index_class <= BaseIndex
    index_class.reset!
  end

  Services::Overseers::Exporters::MaterialReadinessExporter.new.call
end

every(1.day, 'inquiry_product_inventory_update', at: '04:00') do
  service = Services::Resources::Products::UpdateRecentInquiryProductInventory.new
  service.call
end if Rails.env.production?

# every(1.day, 'resync_failed_requests', at: '07:00') do
#   service = Services::Overseers::FailedRemoteRequests::Resync.new
#   service.call
# end if Rails.env.production?


# every(1.day, 'resync_requests_status', at: '08:30') do
#   service = Services::Overseers::FailedRemoteRequests::Resync.new
#   service.verify
# end if Rails.env.production?

every(1.day, 'log_currency_rates', at: '20:00') do
  service = Services::Overseers::Currencies::LogCurrencyRates.new
  service.call
end

every(1.day, 'flush_unavailable_images', at: '20:30') do
  Chewy.strategy(:atomic) do
    service = Services::Customers::CustomerProducts::FlushUnavailableImages.new
    service.call
  end
end

every(1.day, 'refresh_calculated_totals', at: '21:00') do
  service = Services::Overseers::Inquiries::RefreshCalculatedTotals.new
  service.call
end

every(1.day, 'gcloud_run_backups', at: '21:30') do
  service = Services::Shared::Gcloud::RunBackups.new
  service.call
end if Rails.env.production?

every(2.day, 'gcloud_run_backups_alt', at: '22:30') do
  service = Services::Shared::Gcloud::RunBackups.new(send_chat_message: false)
  service.call
end if Rails.env.production?

every(4.day, 'set_slack_ids', at: '10:00') do
  Chewy.strategy(:atomic) do
    service = Services::Overseers::Slack::SetSlackIds.new
    service.call
  end
end

every(1.day, 'set_overseer_monthly_target', if: lambda { |t| t.day == 1 }) do
  puts 'For setting Monthly Targets'
  service = Services::Overseers::Targets::SetMonthlyTarget.new
  service.set_overseer_monthly_target
end

# every(1.month, 'product_inventory_update', :at => '05:00') do
#   service = Services::Resources::Products::UpdateInventory.new
#   service.call
# end if Rails.env.production?

=begin
every(1.day, 'remote_unwanted_requests', at: '22:00') do
  service = Services::Overseers::RequestCronJobs::RemoveRequestCronJob.new
  service.call
end if Rails.env.production?
=end
