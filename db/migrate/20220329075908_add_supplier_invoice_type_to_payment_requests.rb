class AddSupplierInvoiceTypeToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :supplier_invoice_type, :integer
  end
end
