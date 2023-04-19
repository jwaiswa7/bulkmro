# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as :default

  around_perform do |job, block|
    Chewy.strategy(:atomic) do
      block.call
    end
  end

  def perform(service_name, *args)
    service_class = service_name.constantize
    service = service_class.send(:new, *args)
    service.call_later
  end
end
