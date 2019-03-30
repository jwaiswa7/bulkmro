class Services::Overseers::Exporters::GenerateExportsDaily < Services::Shared::BaseService
  def initialize
    export_arr = [
        'ProductsExporter',
        'CompaniesExporter',
        'PurchaseOrdersExporter',
        'SalesInvoiceRowsExporter',
        'SalesInvoicesExporter',
        'SalesInvoicesLogisticsExporter',
        'SalesOrderRowsExporter',
        'SalesOrdersLogisticsExporter'
    ]
    export_arr.each do |value|
      ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
    end
  end
end
