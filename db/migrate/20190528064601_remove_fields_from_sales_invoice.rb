class RemoveFieldsFromSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    remove_column :sales_invoices, :committed_delivery_tat, :integer
    remove_column :sales_invoices, :actual_delivery_tat, :integer
    remove_column :sales_invoices, :delay, :integer
    remove_column :sales_invoices, :delay_reason, :text
    add_column :sales_invoices, :delay_reason, :integer
  end
end
