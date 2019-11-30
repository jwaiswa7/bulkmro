# frozen_string_literal: true

class ApplicationExportJob < ActiveJob::Base
  # include Sidekiq::Worker
  queue_as :default
  # sidekiq_options retry: 1, queue: 'high_priority'

  def perform(*args)
    # GC.start
    service_class = ['Services', 'Overseers', 'Exporters', args[0]].join('::').constantize
    args.shift
    service = service_class.send(:new, *args[0])
    service.build_csv
  end
end
