class Services::Overseers::Exporters::GenerateExportsHourly < Services::Shared::BaseService
  def initialize
    export_arr = [
        'InquiriesExporter',
        'SalesOrdersExporter',
    ]
    export_arr.each do |value|
      if value == 'InquiriesExporter' && !(Export.where(export_type: 1).last.status.in?(['Enqueued', 'Processing']))
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      # else
      #   ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      end
    end
  end
end