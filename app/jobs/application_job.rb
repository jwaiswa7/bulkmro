# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(service_name, *args)
    service_class = service_name.constantize
    service = service_class.send(:new, *args)
    service.call_later
  end
end
