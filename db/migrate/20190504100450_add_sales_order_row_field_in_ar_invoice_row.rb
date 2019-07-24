class AddSalesOrderRowFieldInArInvoiceRow < ActiveRecord::Migration[5.2]
  def change
    add_reference :ar_invoice_request_rows, :sales_order_row, foreign_key: true
  end
end
