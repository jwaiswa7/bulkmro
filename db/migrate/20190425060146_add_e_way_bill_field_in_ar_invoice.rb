class AddEWayBillFieldInArInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :ar_invoices, :e_way, :boolean, :default => false
  end
end
