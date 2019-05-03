class Export < ApplicationRecord
  has_one_attached :report

  scope :not_filtered, -> { where(filtered: false) }

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
    suppliers: 65,
    sales_order_reco: 70,
    kra_report: 90,
    company_report: 91
  }
end
