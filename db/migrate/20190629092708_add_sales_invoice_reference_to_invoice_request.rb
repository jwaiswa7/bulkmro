class AddSalesInvoiceReferenceToInvoiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_requests, :sales_invoice
  end
end
