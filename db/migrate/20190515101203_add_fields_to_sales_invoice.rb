class AddFieldsToSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :committed_delivery_tat, :integer
    add_column :sales_invoices, :actual_delivery_tat, :integer
    add_column :sales_invoices, :delay, :integer
    add_column :sales_invoices, :delay_reason, :text
  end
end
