# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: 'high_priority'

  def perform(service_name, *args)
    service_class = service_name.constantize
    service = service_class.send(:new, *args)
    service.call_later
  end
end
