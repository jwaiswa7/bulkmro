class AddDueDateInInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :due_date, :datetime
  end
end
