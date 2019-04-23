class CreateArInvoicesSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoices_sales_orders, id: false do |t|
      t.belongs_to :ar_invoice, index: true
      t.belongs_to :sales_order, index: true
    end
  end
end
