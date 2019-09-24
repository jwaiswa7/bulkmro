class Services::Overseers::Exporters::GenerateExportsDaily < Services::Shared::BaseService
  def initialize
    export_arr = [
        'MaterialReadinessExporter',
        'SalesOrderRowsExporter',
        'SalesInvoiceRowsExporter',
        'ProductsExporter',
        'CompaniesExporter',
        'SalesInvoicesExporter',
        'SalesInvoicesLogisticsExporter',
        'SalesOrdersLogisticsExporter',
        'PurchaseOrdersExporter'
    ]
    export_arr.each do |value|
      ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
    end
  end
end
