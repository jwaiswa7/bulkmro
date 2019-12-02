class PodRow < ApplicationRecord
  belongs_to :sales_invoice, required: false
  has_many_attached :attachments

  update_index('customer_order_status_report#sales_invoice') { self.sales_invoice.sales_order if self.sales_invoice.present? && self.sales_invoice.sales_order.present? }
end
