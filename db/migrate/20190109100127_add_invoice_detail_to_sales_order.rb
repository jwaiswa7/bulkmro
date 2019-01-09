class AddInvoiceDetailToSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :invoice_total, :decimal
    add_column :sales_orders, :order_total, :decimal
  end
end
