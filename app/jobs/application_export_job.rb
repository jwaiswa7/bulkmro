class ApplicationExportJob < ActiveJob::Base
  queue_as :default

  def perform(arg)
    ['Services', 'Overseers', 'Exporters', arg].join('::').constantize.new.build_csv
  end
end