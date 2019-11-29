# frozen_string_literal: true

class ApplicationExportJob < ActiveJob::Base
  #include Sidekiq::Worker
  queue_as :exports
  #sidekiq_options retry: 1, queue: 'high_priority'

  def perform(*args)
    service_class = ['Services', 'Overseers', 'Exporters', args[0]].join('::').constantize
    args.shift
    service = service_class.send(:new, *args[0])
    service.build_csv
    GC.start
  end
end
