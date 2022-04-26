require 'clockwork'
include Clockwork
# require './config/boot'
require './config/environment'
require 'active_support/time'
require 'sidekiq'
require 'rake'

configure do |config|
  config[:tz] = 'Asia/Kolkata'
  config[:max_threads] = 5
  config[:thread] = true
end

handler do |job, time|
  Chewy.strategy(:atomic)
  puts "Running #{job}, at #{time}"
end

every(30.minutes, 'resync_remote_requests') do
  date = Date.today
  ResyncRemoteRequest.where('hits < 5').where(created_at: date.beginning_of_day..date.end_of_day).find_each(batch_size: 100) do |resync_request|
    service = Services::Resources::Shared::ResyncFailedRequests.new(resync_request)
    service.call
  end
end if Rails.env.production?

every(1.day, 'resync_credit_note', at: '00:30') do
  Resources::CreditNote.create_from_sap
end if Rails.env.production?

every(1.hour, 'adjust_dynos') do
  Services::Shared::Heroku::DynoAdjuster.new
end if Rails.env.production?

every(1.day, 'set_overseer_monthly_target', at: '00:10') do
  puts 'For setting Monthly Targets'
  service = Services::Overseers::Targets::SetMonthlyTarget.new
  service.set_overseer_monthly_target
end

every(1.day, 'purchase_order_reindex', at: '00:50') do
  # deletes old indexes/alias_index
  require 'httparty'
  auth = {username: "#{ENV['ELASTIC_USER_NAME']}", password: "#{ENV['ELASTIC_PASSWORD']}"}
  HTTParty.delete("#{ENV['FOUNDELASTICSEARCH_URL']}/purchase_orders_*", basic_auth: auth)

  # reindex
  index_class = PurchaseOrdersIndex
  if index_class <= BaseIndex
    index_class.reset!
  end
end

every(1.day, 'refresh_indices', at: '01:30') do
  Services::Shared::Chewy::RefreshIndices.new
end

every(1.day, 'reset_indices', at: '02:00') do
  GC.start
  Rails.application.class.load_tasks
  Rake::Task['chewy:parallel:reset'].invoke
  # Dir[[Chewy.indices_path, '/*'].join()].map do |path|
  #   puts "Indexing #{path}"
  #   path.gsub('.rb', '').gsub('app/chewy/', '').classify.constantize.reset!
  #   puts "Indexed #{path}"
  # end
end

every(1.day, 'add_companies_total_amount_records', at: '00:30', if: lambda { |t| t.day == 1 && t.month == 4 }) do
  puts 'For adding customer company total amounts'
  customer_service = Services::Shared::Migrations::AddCompanyTotalAmountFinancialYearwise.new
  customer_service.customer_companies_calculate_total_so_amount

  # puts 'For adding supplier company total amounts'
  # supplier_service = Services::Shared::Migrations::AddCompanyTotalAmountFinancialYearwise.new
  # supplier_service.supplier_companies_calculate_total_po_amount
end

every(1.day, 'inquiry_product_inventory_update', at: '05:30') do
  service = Services::Resources::Products::UpdateRecentInquiryProductInventory.new
  service.call
end if Rails.env.production?

every(1.day, 'refresh_smart_queue', at: '06:00') do
  RefreshSmartQueueJob.perform_later
end if Rails.env.production?

every(1.day, 'product_inventory_update_for_saint_gobain', at: ['07:00', '11:00', '15:00', '19:00']) do
  service = Services::Resources::Products::UpdateInventoryForSaintGobain.new
  service.call
end if Rails.env.production?

every(1.day, 'product_inventory_update_for_henkel', at: ['07:30', '11:30', '15:30', '19:30']) do
  service = Services::Resources::Products::UpdateInventoryForHenkel.new
  service.call
end if Rails.env.production?

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

every(1.day, 'generate_exports_daily', at: '22:00') do
  # to-do check for memory leaks on heroku
  Chewy.strategy(:atomic) do
    service = Services::Overseers::Exporters::GenerateExportsDaily.new
    service.call
  end
end

every(2.day, 'gcloud_run_backups_alt', at: '22:30') do
  service = Services::Shared::Gcloud::RunBackups.new(send_chat_message: false)
  service.call
end if Rails.env.production?

every(4.day, 'set_slack_ids', at: '23:00') do
  Chewy.strategy(:atomic) do
    service = Services::Overseers::Slack::SetSlackIds.new
    service.call
  end
end

# every(1.day, 'send_inventory_status_to_saint_gobain_customer', at: '19:30') do
#   InventoryStatusMailer.send_inventory_status_to_customer.deliver_now
# end if Rails.env.production?

# every(3.hour, 'update_admin_dashboard_cache') do
#   UpdateAdminDashboardCacheJob.perform_later
# end if Rails.env.production?

# every(4.hour, 'generate_exports_hourly') do
#   Chewy.strategy(:atomic) do
#     Services::Overseers::Exporters::GenerateExportsHourly.new
#   end
# end if Rails.env.production?

# every(1.day, 'remote_unwanted_requests', at: '22:00') do
#   service = Services::Overseers::RequestCronJobs::RemoveRequestCronJob.new
#   service.call
# end if Rails.env.production?

# every(90.minutes, 'bible_upload') do
#   Chewy.strategy(:atomic) do
#     @bible_upload_queue = BibleUpload.where(status: 'Pending').first
#     if @bible_upload_queue.present?
#       service = Services::Overseers::Bible::BaseService.new
#       service.call(@bible_upload_queue)
#     end
#   end
# end

# every(1.day, 'resync_failed_requests', at: '07:00') do
#   service = Services::Overseers::FailedRemoteRequests::Resync.new
#   service.call
# end if Rails.env.production?

# every(1.day, 'resync_requests_status', at: '08:30') do
#   service = Services::Overseers::FailedRemoteRequests::Resync.new
#   service.verify
# end if Rails.env.production?


