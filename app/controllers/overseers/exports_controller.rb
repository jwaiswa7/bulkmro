class Overseers::ExportsController < Overseers::BaseController
  def index
    authorize_acl :export

    @export_service_hash = { "inquiries" => "inquiries/export_all.csv", "sales_orders" => "sales_orders/export_all.csv", "products" => "products/export_all.csv", "companies" => "companies/export_all.csv", "sales_order_logistics" => "sales_orders/export_for_logistics.csv", "purchase_orders" => "purchase_orders/export_all.csv", "sales_order_rows" => "sales_orders/export_rows.csv", "sales_invoice_logistics" => "sales_invoice_logistics/export_all.csv", "sales_invoices" => "sales_invoices/export_all.csv", "sales_invoice_rows" => "sales_invoice_rows/export_all.csv", "sales_order_sap" => "sales_orders/export_for_sap.csv", "suppliers" => "suppliers/export_all.csv", "sales_order_reco" => "sales_orders/export_for_reco.csv", "activities" => "activities/export_all.csv", "company_reviews" => "company_reviews/export_all.csv", "kra_report" => "inquiries/export_kra_report.csv", "inquiries_tat" => "inquiries/export_inquiries_tat.csv", "customer_order_status_report" => "", "company_report" => "inquiries/export_company_report.csv", "pipeline_report" => "inquiries/export_pipeline_report.csv", "customer_product" => "customer_product/export_all.csv", "material_readiness_queue" => "purchase_orders/export_material_readiness.csv", "amat_customer_portal" => ""}

    @exports_all = Export.all.group_by(&:export_type).except(nil)
    #respond_to do |format|
    #  format.json {render 'index'}
    #  format.html {render 'index'}
    #end
  end

  # def generate_export
  #   authorize_acl :export
  #
  #   service = ['Services', 'Overseers', 'Exporters', (params[:export]['export_type'].parameterize(separator: '_') + '_exporter').classify].join('::').constantize.new
  #   service.call
  #
  #   redirect_to overseers_exports_path, notice: set_flash_message('Export started', 'success')
  # end
end
