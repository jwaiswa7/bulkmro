class Services::Overseers::Exporters::GenerateExportsDaily < Services::Shared::BaseService
  def initialize
    export_arr = [
        'SalesInvoicesExporter',
        'ProductsExporter',
        'SalesOrderRowsExporter',
        'SalesInvoiceRowsExporter',
        'CompaniesExporter',
        'SalesInvoicesLogisticsExporter',
        'SalesOrdersLogisticsExporter',
        'PurchaseOrdersExporter'
    ]
    export_arr.each do |value|
      ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
    end
  end
end
