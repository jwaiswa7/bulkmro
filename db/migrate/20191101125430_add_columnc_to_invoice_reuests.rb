class AddColumncToInvoiceReuests < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_requests, :is_checked, :boolean, default: false
  end
end
