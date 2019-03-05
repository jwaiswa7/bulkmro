class Export < ApplicationRecord
  has_one_attached :report

  enum export_type: {
      inquiries: 1,
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
      image_readers: 55,
      image_readers_for_date: 60,
      company_reviews: 70,
      activities: 65
  }
end
