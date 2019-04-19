class AddCompletedToSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :delivery_completed, :boolean,:default => true
  end
end
