class AddSalesInvoiceRefrenceToInvoiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :ar_invoice_requests, :sales_invoice
    remove_column :ar_invoice_requests, :ar_invoice_number
  end
end
