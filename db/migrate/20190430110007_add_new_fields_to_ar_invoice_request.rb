class AddNewFieldsToArInvoiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :ar_invoice_request_rows, :delivered_quantity, :decimal, default: 0.0
  end
end
