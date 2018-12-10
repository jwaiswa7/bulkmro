class Services::Overseers::Exporters::GenerateExports < Services::Shared::BaseService
  def initialize
    export_arr = %w(InquiriesExporter ProductsExporter CompaniesExporter PurchaseOrdersExporter SalesInvoiceRowsExporter SalesInvoicesExporter SalesInvoicesLogisticsExporter SalesOrderRowsExporter SalesOrdersExporter SalesOrdersLogisticsExporter)
    export_arr.each do |value|
      ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
    end
  end
end