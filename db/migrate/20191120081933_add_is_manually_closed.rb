class AddIsManuallyClosed < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :is_manual_closed, :boolean, default: false
  end
end
