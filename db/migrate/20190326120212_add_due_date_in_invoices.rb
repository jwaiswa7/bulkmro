class AddDueDateInInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :due_date, :datetime unless column_exists? :sales_invoices, :due_date
  end
end
