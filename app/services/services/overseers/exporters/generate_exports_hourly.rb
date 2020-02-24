class Services::Overseers::Exporters::GenerateExportsHourly < Services::Shared::BaseService
  
  def initialize
    export_hash = {
      'inquiries': 'InquiriesExporter',
      'sales_orders': 'SalesOrdersExporter'
    }

    export_hash.each do |key, value|
      unless Export.where(export_type: key).last.status.in?(['Enqueued', 'Processing'])
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      end
    end
  end
end