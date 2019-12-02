class Export < ApplicationRecord
  has_one_attached :report

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
    sales_invoice_logistics: 30,
    sales_order_rows: 35,
    sales_orders: 40,
    sales_order_logistics: 45,
    sales_order_sap: 50,
    activities: 55,
    company_reviews: 60,
    kra_report: 90,
    suppliers: 65,
    sales_order_reco: 70,
    company_report: 91,
    customer_order_status_report: 92,
    pipeline_report: 93,
    monthly_sales_report: 94,
    customer_product: 95,
    material_readiness_queue: 96,
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
