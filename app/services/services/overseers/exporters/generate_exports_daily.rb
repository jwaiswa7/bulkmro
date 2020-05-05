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
        'material_readiness': 'MaterialReadinessExporter'
    }
  end

  def call
    @export_hash.each do |key, value|
      last_export = Export.where(export_type: key).last
      if last_export.status == 'Completed' || (Export.where(export_type: key).last.status.in?(['Enqueued', 'Processing']) && !last_export.report.attachment.present?)
        ['Services', 'Overseers', 'Exporters', value].join('::').constantize.new.call
        sleep 1800 if key != @export_hash.keys.last
      end
    end
  end
end