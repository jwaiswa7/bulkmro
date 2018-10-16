class AddStatusToSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :status, :integer, index: true
  end
end
