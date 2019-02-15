class ApplicationExportJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    service_class = ['Services', 'Overseers', 'Exporters', args[0]].join('::').constantize
    args.shift
    service = service_class.send(:new, *args[0])
    service.build_csv
  end
end