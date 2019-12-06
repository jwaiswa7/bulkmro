class Export < ApplicationRecord
  has_one_attached :report
  paginates_per 24
  scope :not_filtered, -> { where(filtered: false) }
  scope :completed, -> { where(status: 'Completed') }

  enum export_type: {
    inquiries: 1,
    inquiries_tat: 2,
    products: 5,
    companies: 10,
    purchase_orders: 15,
    sales_invoice_rows: 20,
    sales_invoices: 25,
    sales_invoices_logistics: 30,
    sales_order_rows: 35,
    sales_orders: 40,
    sales_orders_logistics: 45,
    sales_orders_sap: 50,
    activities: 55,
    company_review: 60,
    kra_reports: 90,
    suppliers: 65,
    sales_orders_reco: 70,
    company_reports: 91,
    customer_order_status_reports: 92,
    pipeline_reports: 93,
    monthly_sales_report: 94,
    customer_products: 95,
    material_readiness: 96,
    amat_customer_portal: 97,
    sales_orders_bible_format: 100
  }
  enum status: {
      'Enqueued': 1,
      'Processing': 2,
      'Completed': 3,
      'Failed': 4
  }
end
