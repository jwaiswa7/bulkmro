# frozen_string_literal: true

class UpdateAdminDashboardCacheJob < ActiveJob::Base
  # include Sidekiq::Worker
  queue_as :default
  # sidekiq_options retry: 1, queue: 'high_priority'

  def perform
    # GC.start
    service = Services::Overseers::Dashboards::Admin.new
    service.call
  end
end
