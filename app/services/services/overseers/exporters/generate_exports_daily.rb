class Services::Overseers::Exporters::GenerateExportsDaily < Services::Overseers::Exporters::BaseExporter

  def initialize
    @export_hash = {
        'inquiries': 'InquiriesExporter',
        'products': 'ProductsExporter',
        'companies': 'CompaniesExporter',
        'purchase_orders': 'PurchaseOrdersExporter',
        'sales_invoices': 'SalesInvoicesExporter',
        'activities': 'ActivitiesExporter',
        'suppliers': 'SuppliersExporter',
        'sales_orders': 'SalesOrdersExporter',
    }
  end

  def call
    @export_hash.each do |key, value|
      unless Export.where(export_type: key).last.status.in?(['Enqueued', 'Processing'])
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
        sleep 1800
      end
    end
  end
end