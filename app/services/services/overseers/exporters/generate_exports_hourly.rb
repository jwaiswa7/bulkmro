class Services::Overseers::Exporters::GenerateExportsHourly < Services::Shared::BaseService
  
  def initialize
    export_hash = {
      'inquiries': 'InquiriesExporter',
      'products': 'ProductsExporter',
      'companies': 'CompaniesExporter',
      'purchase_orders': 'PurchaseOrdersExporter',
      'sales_invoices': 'SalesInvoicesExporter',
      'sales_orders': 'SalesOrdersExporter',
      'sales_order_sap': 'SalesOrdersSapExporter',
      'activities': 'ActivitiesExporter',
      'company_reviews': 'CompanyReviewExporter',
      'suppliers': 'SuppliersExporter',
      'sales_order_reco': 'SalesOrdersRecoExporter',
      'customer_product': 'CustomerProductsExporter',
      'material_readiness_queue': 'MaterialReadinessExporter',
    }

    export_hash.each do |key, value|
      unless Export.where(export_type: key).last.status.in?(['Enqueued', 'Processing'])
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
      end
    end
  end
end