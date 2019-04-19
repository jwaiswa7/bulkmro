class Services::Overseers::Exporters::GenerateExportsHourly < Services::Shared::BaseService
  def initialize
    export_arr = [
        'InquiriesExporter',
        'SalesOrdersExporter',
    ]
    export_arr.each do |value|
      ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
    end
  end
end