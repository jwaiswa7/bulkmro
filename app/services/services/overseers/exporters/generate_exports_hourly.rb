class Services::Overseers::Exporters::GenerateExportsHourly < Services::Overseers::Exporters::BaseExporter
  
  def initialize
    @export_hash = {
      'inquiries': 'InquiriesExporter',
      'products': 'ProductsExporter'
      # 'companies': 'CompaniesExporter',
      # 'purchase_orders': 'PurchaseOrdersExporter',
      # 'sales_invoices': 'SalesInvoicesExporter',
      # 'sales_orders': 'SalesOrdersExporter',
      # 'activities': 'ActivitiesExporter',
      # 'suppliers': 'SuppliersExporter'
      # 'customer_product': 'CustomerProductsExporter',
    }
  end

  def call
    @export_hash.each do |key, value|
      unless Export.where(export_type: key).last.status.in?(['Enqueued', 'Processing'])
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      end
    end
  end
end