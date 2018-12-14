class RemovePoNumberFromPoRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :po_requests, :purchase_order_number, :integer
  end
end