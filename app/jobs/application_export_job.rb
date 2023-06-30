# frozen_string_literal: true

class ApplicationExportJob < ActiveJob::Base
  # include Sidekiq::Worker
  queue_as :high_priority
  # sidekiq_options retry: 1, queue: 'high_priority'

  # If record is no longer available, it is safe to ignore
  discard_on ActiveJob::DeserializationError

  discard_on ActiveRecord::RecordNotFound

  def perform(*args)
    # GC.start
    service_class = ['Services', 'Overseers', 'Exporters', args[0]].join('::').constantize
    args.shift
    service = service_class.send(:new, *args[0])
    service.build_csv
  end
end
