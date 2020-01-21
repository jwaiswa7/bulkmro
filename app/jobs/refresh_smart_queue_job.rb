# frozen_string_literal: true

class RefreshSmartQueueJob < ActiveJob::Base
  # include Sidekiq::Worker
  queue_as :default
  # sidekiq_options retry: 1, queue: 'high_priority'

  def perform
    # GC.start
    Chewy.strategy(:atomic) do
      service = Services::Overseers::Inquiries::RefreshSmartQueue.new
      service.call
    end
  end
end
