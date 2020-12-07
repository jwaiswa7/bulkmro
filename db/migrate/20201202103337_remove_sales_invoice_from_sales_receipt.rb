class RemoveSalesInvoiceFromSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    remove_reference :sales_receipts, :sales_invoice, foreign_key: true
  end
end
