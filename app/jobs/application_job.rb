# frozen_string_literal: true

require "timeout"

class ApplicationJob < ActiveJob::Base
  queue_as :priority_queue

  # If record is no longer available, it is safe to ignore
  discard_on ActiveJob::DeserializationError

  discard_on ActiveRecord::RecordNotFound

  discard_on ActiveRecord::RecordInvalid

  around_perform do |job, block|
    Chewy.strategy(:atomic) do
      block.call
    end
  end

  def perform(service_name, *args)
    service_class = service_name.constantize
    service = service_class.send(:new, *args)

    begin
      Timeout.timeout(30) do
        service.call_later
      end
    rescue Timeout::Error
      raise "Timeout reached for job: #{self.class.name}"
    end
  end
end
