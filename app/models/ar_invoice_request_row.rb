class ArInvoiceRequestRow < ApplicationRecord
  belongs_to :ar_invoice_request, class_name: 'ArInvoiceRequest'
  belongs_to :sales_order, class_name: 'SalesOrder'
  belongs_to :inward_dispatch_row, class_name: 'InwardDispatchRow'
  belongs_to :product, class_name: 'Product'
  validate :is_delivered_quantity_less

  def is_delivered_quantity_less
      errors.add(:delivered_quantity, 'must be less than Existing Quantity ') if delivered_quantity > quantity
  end
end
