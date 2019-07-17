class AddForeignKeyInArInvoiceRequestRow < ActiveRecord::Migration[5.2]
  def change
    add_reference :ar_invoice_request_rows, :product, foreign_key: true, index: true
  end
end
