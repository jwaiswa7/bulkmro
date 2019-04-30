class ArInvoiceRequestRow < ApplicationRecord
  belongs_to :ar_invoice_request, class_name: 'ArInvoiceRequest'
  belongs_to :sales_order, class_name: 'SalesOrder'
  belongs_to :inward_dispatch_row, class_name: 'InwardDispatchRow'

end
