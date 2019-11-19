class Services::Overseers::Exporters::GenerateExportsHourly < Services::Shared::BaseService
  def initialize
    export_arr = [
        'InquiriesExporter',
        'SalesOrdersExporter',
    ]
    export_arr.each do |value|
      if !(Export.last.status.in?(['Enqueued', 'Processing']))
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      end
    end
  end
end