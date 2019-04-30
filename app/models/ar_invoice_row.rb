class ArInvoiceRow < ApplicationRecord
  belongs_to :ar_invoice, class_name: 'ArInvoice'
  belongs_to :sales_order, class_name: 'SalesOrder'
  belongs_to :inward_dispatch_row, class_name: 'InwardDispatchRow'

end
